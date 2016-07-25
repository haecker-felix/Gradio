# Gradio
A GTK3 app for finding and listening to internet radio stations.

<p align="center">
  <img alt="Library View" src="http://i.imgur.com/AOP92Mg.png" />
</p>

## Releases and packages
- All Gradio releases can be found here: https://github.com/haecker-felix/gradio/releases

## Dependencies
For gradio:
* glib-2.0
* gtk+-3.0 _>=3.18_
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

Stable versions of gradio is available on GetDeb repositories for Xenial release (16.04 LTS). You can [learn more](http://www.getdeb.net/updates/ubuntu/16.04/) about adding GetDeb repositories to your system.

For daily releases, you can add the [this ppa](https://code.launchpad.net/~haecker-felix/+archive/ubuntu/gradio-daily).
```shell
deb http://ppa.launchpad.net/haecker-felix/gradio-daily/ubuntu xenial main
deb-src http://ppa.launchpad.net/haecker-felix/gradio-daily/ubuntu xenial main
sudo apt-get update
sudo apt-get install gradio
```

### Arch
For Arch users, you can install the latest git version from AUR package using 
```
yaourt -S gradio-git
```

## Uninstall
If you install from source you must have the original compiled source to uninstall. `cmake` does not provide a `make uninstall` but list all the files installed on the system in `install_manifest.txt`. You can delete each file listed seperatly or run:
```bash
cd ~/Downloads/gradio/build
sudo xargs rm < install_manifest.txt
```

