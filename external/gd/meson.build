gnome_module = import('gnome')

subdir('libgd')

sources = [
	'libgd/gd.h',
	'libgd/gd-types-catalog.h',
	'libgd/gd-types-catalog.c',
	'libgd/gd-entry-focus-hack.c',
	'libgd/gd-entry-focus-hack.h',
	'libgd/gd-icon-utils.c',
	'libgd/gd-icon-utils.h',
	'libgd/gd-main-box.c',
	'libgd/gd-main-box-child.c',
	'libgd/gd-main-box-child.h',
	'libgd/gd-main-box-generic.c',
	'libgd/gd-main-box-generic.h',
	'libgd/gd-main-box.h',
	'libgd/gd-main-box-item.c',
	'libgd/gd-main-box-item.h',
	'libgd/gd-main-icon-box.c',
	'libgd/gd-main-icon-box-child.c',
	'libgd/gd-main-icon-box-child.h',
	'libgd/gd-main-icon-box.h',
	'libgd/gd-main-icon-box-icon.c',
	'libgd/gd-main-icon-box-icon.h',
	'libgd/gd-notification.c',
	'libgd/gd-notification.h',
	gdres,
	'libgd/gd-tagged-entry.c',
	'libgd/gd-tagged-entry.h'
]


gd_lib = static_library( 'libgd', sources, dependencies : [glib, gobject, gio, gtk, libm], include_directories : include_directories('.'), install : false)

gd = declare_dependency(link_with : gd_lib, include_directories : include_directories('.'))
