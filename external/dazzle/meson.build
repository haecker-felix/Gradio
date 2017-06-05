gnome_module = import('gnome')

sources = [
	'libdazzle/dazzle.h',
	'libdazzle/dzl-util-private.h',
	'libdazzle/dzl-stack-list.h',
	'libdazzle/dzl-stack-list.c',
	'libdazzle/dzl-animation.h',
	'libdazzle/dzl-animation.c',
	'libdazzle/dzl-frame-source.h',
	'libdazzle/dzl-frame-source.c',
	'libdazzle/dzl-rect-helper.h',
	'libdazzle/dzl-rect-helper.c',
]


dazzle_lib = static_library( 'libdazzle', sources, dependencies : [glib, gobject, gio, gtk, libm], include_directories : include_directories('.'), install : false)

dazzle = declare_dependency(link_with : dazzle_lib, include_directories : include_directories('.'))
