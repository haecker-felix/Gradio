# Gradio
A GTK3 application for finding and listening to internet radio stations.

<p align="center">
  <img alt="Library View" src="http://i.imgur.com/yMK0v1b.png" />
  <img alt="Search View" src="http://i.imgur.com/WibRApn.png)" />
</p>

## Features
* Search radio stations (worldwide)
* Create your own library
* Vote for radio stations
* Visit their homepage
* Notifications
* Grid/List view

## Dependencies
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
For Ubuntu based distros (16.04) you can add the [daily ppa](https://code.launchpad.net/~haecker-felix/+archive/ubuntu/gradio-daily).
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

## To-do
* MPRIS support
* Playlists (*.m3u) support
