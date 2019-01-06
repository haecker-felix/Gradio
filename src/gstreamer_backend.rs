use gstreamer::prelude::*;
use gstreamer::{Element, Bin, Pipeline, Pad, PadProbeId, State, ElementFactory};

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                      //
//  # Gstreamer Pipeline                                                                                //
//                                            -----      --------       ------------                    //
//                                           |     | -> | queue [1] -> | muxsinkbin |                   //
//    --------------      --------------     |     |     --------       ------------                    //
//   | uridecodebin | -> | audioconvert | -> | tee |                                                    //
//    --------------      --------------     |     |     --------       ---------------                 //
//                                           |     | -> | queue [2] -> | autoaudiosink |                //
//                                            -----      --------       ---------------                 //
//                                                                                                      //
//                                                                                                      //
//                                                                                                      //
//  We use the two source pads to block the dataflow, so we can change the muxsinkbin.                  //
//   - 1 -> file_srcpad                                                                                 //
//   - 2 -> audio_srcpad                                                                                //
//                                                                                                      //
//  The dataflow gets blocked when the song changes.                                                    //
//                                                                                                      //
//                                                                                                      //
//  # muxsinkbin:  (gstreamer Bin)                                                                      //
//    --------------------------------------------------------------                                    //
//   |                  -----------       --------      ----------  |                                   //
//   | ( ghostpad ) -> | vorbisenc | ->  | oggmux | -> | filesink | |                                   //
//   |                  -----------       --------      ----------  |                                   //
//    --------------------------------------------------------------                                    //
//                                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////

pub struct GstreamerBackend{
    pub pipeline: Pipeline,

    pub uridecodebin: Element,
    pub audioconvert: Element,
    pub tee: Element,

    pub audio_queue: Element,
    pub autoaudiosink: Element,
    pub audio_srcpad: Pad,
    pub audio_blockprobe_id: Option<PadProbeId>,

    pub file_queue: Element,
    pub muxsinkbin: Option<Bin>,
    pub file_srcpad: Pad,
    pub file_blockprobe_id: Option<PadProbeId>,
}

impl GstreamerBackend{
    pub fn new() -> Self{
        // create gstreamer pipeline
        let pipeline = Pipeline::new("recorder_pipeline");

        // create pipeline elements
        let uridecodebin = ElementFactory::make("uridecodebin", "uridecodebin").unwrap();
        let audioconvert = ElementFactory::make("audioconvert", "audioconvert").unwrap();
        let tee = ElementFactory::make("tee", "tee").unwrap();
        let audio_queue = ElementFactory::make("queue", "audio_queue").unwrap();
        let autoaudiosink = ElementFactory::make("autoaudiosink", "autoaudiosink").unwrap();
        let file_queue = ElementFactory::make("queue", "file_queue").unwrap();

        // link pipeline elements
        pipeline.add_many(&[&uridecodebin, &audioconvert, &tee, &audio_queue, &autoaudiosink, &file_queue]).unwrap();
        Element::link_many(&[&audioconvert, &tee]).unwrap();
        let tee_tempmlate = tee.get_pad_template ("src_%u").unwrap();

        // link tee -> queue
        let tee_file_srcpad = tee.request_pad(&tee_tempmlate, None, None).unwrap();
        let _ = tee_file_srcpad.link(&file_queue.get_static_pad("sink").unwrap());

        // link tee -> queue -> autoaudiosink
        let tee_audio_srcpad = tee.request_pad(&tee_tempmlate, None, None).unwrap();
        let _ = tee_audio_srcpad.link(&audio_queue.get_static_pad("sink").unwrap());
        let _ = audio_queue.link(&autoaudiosink);

        // dynamically link uridecodebin element with audioconvert element
        let convert = audioconvert.clone();
        uridecodebin.connect_pad_added(move |_, src_pad|{
            let sink_pad = convert.get_static_pad("sink").expect("Failed to get static sink pad from convert");
            if sink_pad.is_linked() {
                return; // We are already linked. Ignoring.
            }

            let new_pad_caps = src_pad.get_current_caps().expect("Failed to get caps of new pad.");
            let new_pad_struct = new_pad_caps.get_structure(0).expect("Failed to get first structure of caps.");
            let new_pad_type = new_pad_struct.get_name();

            if new_pad_type.starts_with("audio/x-raw") { // check if new_pad is audio
                let _ = src_pad.link(&sink_pad);
                return;
            }
        });

        let file_srcpad = file_queue.get_static_pad("src").unwrap();
        let audio_srcpad = audio_queue.get_static_pad("src").unwrap();

        let mut pipeline = Self{
            pipeline,
            uridecodebin,
            audioconvert,
            tee,
            audio_queue,
            autoaudiosink,
            audio_srcpad,
            audio_blockprobe_id: None,
            file_queue,
            muxsinkbin: None,
            file_srcpad,
            file_blockprobe_id: None,
        };

        pipeline.create_muxsinkbin("/dev/null");
        pipeline
    }

    pub fn set_state(&self, state: gstreamer::State){
        let _ = self.pipeline.set_state(state);
    }

    pub fn block_dataflow(&mut self){
        // Audio branch
        let audio_id = self.audio_srcpad.add_probe (gstreamer::PadProbeType::BLOCK_DOWNSTREAM, move|_, _|{
            gstreamer::PadProbeReturn::Ok
        }).unwrap();

        // File branch
        let muxsinkbin = self.muxsinkbin.clone();
        let file_id = self.file_srcpad.add_probe (gstreamer::PadProbeType::BLOCK_DOWNSTREAM, move|_, _|{
            // Dataflow is blocked
            debug!("Pad is blocked now.");

            debug!("Push EOS into muxsinkbin sinkpad...");
            let sinkpad = muxsinkbin.clone().unwrap().get_static_pad("sink").unwrap();
            sinkpad.send_event(gstreamer::Event::new_eos().build());

            gstreamer::PadProbeReturn::Ok
        }).unwrap();

        // We need the padprobe id later to remove the block probe
        self.file_blockprobe_id = Some(file_id);
        self.audio_blockprobe_id = Some(audio_id);
    }

    pub fn new_source_uri(&mut self, source: &str){
        debug!("Stop pipeline...");
        let _ = self.pipeline.set_state(State::Null);

        debug!("Set new source uri...");
        self.uridecodebin.set_property("uri", &source).unwrap();

        debug!("Start pipeline...");
        let _ = self.pipeline.set_state(State::Playing);
    }

    pub fn new_filesink_location(&mut self, location: &str){
        debug!("Update filesink location to \"{}\"...", location);

        debug!("Destroy old muxsinkbin");
        let muxsinkbin = self.muxsinkbin.take().unwrap();
        let _ = muxsinkbin.set_state(State::Null);
        self.pipeline.remove(&muxsinkbin).unwrap();

        debug!("Create new muxsinkbin");
        self.create_muxsinkbin(location);

        debug!("Remove block probe...");
        self.file_srcpad.remove_probe(self.file_blockprobe_id.take().unwrap());
        self.audio_srcpad.remove_probe(self.audio_blockprobe_id.take().unwrap());

        debug!("Everything ok.");
    }

    fn create_muxsinkbin(&mut self, location: &str){
        // Create vorbisenc
        let vorbisenc = ElementFactory::make("vorbisenc", "vorbisenc").unwrap();

        // Create oggmux
        let oggmux = ElementFactory::make("oggmux", "oggmux").unwrap();

        // Create filesink
        let filesink = ElementFactory::make("filesink", "filesink").unwrap();
        filesink.set_property("location", &location).unwrap();

        // Create bin
        let bin = Bin::new("bin");
        bin.set_property("message-forward", &true).unwrap();

        // Add elements to bin and link them
        bin.add(&vorbisenc).unwrap();
        bin.add(&oggmux).unwrap();
        bin.add(&filesink).unwrap();
        Element::link_many(&[&vorbisenc, &oggmux, &filesink]).unwrap();

        // Add bin to pipeline
        self.pipeline.add(&bin).unwrap();

        // Link queue src pad with vorbisenc sinkpad using a ghostpad
        let vorbisenc_sinkpad = vorbisenc.get_static_pad("sink").unwrap();

        let ghostpad = gstreamer::GhostPad::new("sink", &vorbisenc_sinkpad).unwrap();
        bin.add_pad(&ghostpad).unwrap();
        bin.sync_state_with_parent().unwrap();

        if self.file_srcpad.link(&ghostpad) != gstreamer::PadLinkReturn::Ok {
            warn!("Queue src pad cannot linked to vorbisenc sinkpad");
        }

        self.muxsinkbin = Some(bin);
    }
}
