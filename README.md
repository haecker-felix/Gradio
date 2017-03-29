____
You can find updated development information to Gradio 6.0 here: 
https://github.com/haecker-felix/gradio/tree/gradio_6
____

# Gradio

A GTK3 app for finding and listening to internet radio stations.

<p align="center">
  <img alt="demo_img" src="https://raw.githubusercontent.com/haecker-felix/gradio/master/data/appdata/gradio01.png">
</p>

## Install Gradio

### Ubuntu 
A PPA is available. Gradio needs Ubuntu 16.04 or higher.

[More details](https://code.launchpad.net/~haecker-felix/+archive/ubuntu/gradio-daily)


### Fedora
A copr is available. Gradio needs Fedora 24 or higher.

[More details](https://copr.fedorainfracloud.org/coprs/heikoada/gradio/)


### openSUSE 
Gradio is available in the official openSUSE repository. 


### Arch Linux
Gradio is available in the AUR. 

[More details](https://aur.archlinux.org/packages/?O=0&K=Gradio)


### Solus
Gradio is available in the official Solus repository. 

[More details](https://git.solus-project.com/packages/gradio/)

### Other 
For unsupported distributions you can install gradio from source:

```bash
cd ~/Downloads
git clone https://github.com/haecker-felix/gradio.git
cd gradio
./autogen.sh
make
sudo make install
```

## Releases
All Gradio releases can be found [here](https://github.com/haecker-felix/gradio/releases)


## FAQ

### A station is missing. How I can add a new station to the database?
It is possible to add new stations here: 

http://www.radio-browser.info

In a further release of gradio it will be easier to add new stations.


### A feature is missing. Can you add it?
Maybe. Open a new Github issue and I'll look at it.


### Why is there no ubuntu 14.04 support?
Gradio needs GTK 3.14 or higher. Ubuntu 14.04 provides GTK 3.12 which is definitely too old.


### Does a flatpak exist?
Yes! More information here:
https://github.com/haecker-felix/gradio/wiki/How-to-install-Gradio-as-Flatpak


## Technical Details
### Dependencies
For gradio:
* glib-2.0
* gtk+-3.0 _>=3.14_
* gstreamer-1.0
* json-glib-1.0
* gio-2.0
* webkit2gtk-4.0
* libsoup-2.4

For compiling:
* General c/c++ libs & compiler
* git
* appstream-util / appstream-glib
