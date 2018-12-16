# Radio
Find and listen to internet radio stations

![alt text](https://gitlab.gnome.org/haecker-felix/Radio/raw/rust_port/data/icons/hicolor/scalable/apps/de.haeckerfelix.Gradio.svg "Logo")

## Development notes
- This is a WIP branch. Currently Gradio is ported from Vala to Rust. 
- If you want to see the old stable Vala version, [click here](https://gitlab.gnome.org/haecker-felix/Radio/tree/master). 
- Gradio will be renamed from 'Gradio' to 'Radio'.  

## Available on Flathub
<a href='https://flathub.org/apps/details/de.haeckerfelix.gradio'><img width='240' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.png'/></a>

## FAQ
- Why the rename from 'Gradio' to 'Radio'

Because the old name was terrible. Nobody knows how to pronounce it right (not even me). And it was often misspelled as "GRadio". 

- Will the app-id be changed?

I'm still not sure, but likely not.

- Why I cannot edit stations anymore?

The edit feature is disabled because of vandalism. I cannot change this. [More information here](http://www.radio-browser.info/gui/#/) and [here](https://github.com/segler-alex/radiobrowser-api/issues/39)

- Will Radio compatible with the Librem 5?

Yes! We use the awesome [libhandy](https://source.puri.sm/Librem5/libhandy) library to make the interface adaptive.

- Which database does Radio use?

[radio-browser.info](http://www.radio-browser.info/gui/#/). It's a community database. Everybody can add/edit information.

## Building
Radio can be built and run with [Gnome Builder](https://wiki.gnome.org/Apps/Builder) >= 3.28.
Just clone the repo and hit the run button!

You can get Builder from [here](https://wiki.gnome.org/Apps/Builder/Downloads).

