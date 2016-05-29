# gradio
GTK 3 application for finding and listening to internet radio.

<div style="text-align: center;">

![Library](http://i.imgur.com/yMK0v1b.png)
![Search](http://i.imgur.com/WibRApn.png)

</div>

## Features
* Search radio stations (worldwide)
* Add them to your library
* Vote for radio stations
* Visit their homepage
* Notifications

## Dependecies
For gradio:
* glib-2.0
* gtk+-3.0 _>=3.14_
* gstreamer-1.0
* json-glib-1.0
* gio-2.0
* gee-0.8
* libsoup-2.4

For compiling:
* General c/c++ libs & compiler
* cmake
* git
* valac

**Debian**
```bash
sudo apt-get install build-essential valac cmake glib2.0 gtk+3.0 gstreamer1.0 libjson-glib-dev libsoup2.4
```

## Install
### Source
```bash
cd ~/Downloads
git clone https://github.com/haecker-felix/gradio.git
cd gradio
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
sudo make install
```

### Ubuntu
For Ubuntu based ditros you can add the [daily ppa](https://code.launchpad.net/~haecker-felix/+archive/ubuntu/gradio-daily).
For 16.04 based ditros:
```
deb http://ppa.launchpad.net/haecker-felix/gradio-daily/ubuntu xenial main
deb-src http://ppa.launchpad.net/haecker-felix/gradio-daily/ubuntu xenial main
sudo apt-get update
sudo apt-get install gradio
```

## Uninstall
If you install from source you must have the original compiled source to uninstall. `cmake` does not provide a `make uninstall` but list all the files installed on the system in `install_manifest.txt`. You can delete each file listed seperatly or run:
```bash
cd ~/Downloads/gradio/build
sudo xargs rm < install_manifest.txt
```

## Translations
Translations are handeled by [gettext](http://www.gnu.org/software/gettext/manual/gettext.html).
1. Fork this repository
2. Create a new branch for the language you wish to up-date/create (ex. fr, de, es, jp, etc..)
3. Duplicate the `gradio/po/gradio.pot` and rename it `<language code>.po` ([language codes can be found in the manual](http://www.gnu.org/software/gettext/manual/gettext.html#Usual-Language-Codes))
4. Translate strings and submit a pull request upstream

## To-do
* MPRIS support
