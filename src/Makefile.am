bin_PROGRAMS = gradio

gresource_file = $(top_srcdir)/data/gradio.gresource.xml

AM_VALAFLAGS = \
	--gresources $(gresource_file)	\
	--enable-experimental

resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data --generate-source $<

BUILT_SOURCES = resources.c

gradio_SOURCES = \
	$(BUILT_SOURCES) \
	config.vapi \
	data/codec-installer.vala \
	data/radio-browser.vala \
	data/settings.vala \
	data/provider/category-item-provider.vala \
	data/provider/image-provider.vala \
	data/provider/radio-station-provider.vala \
	core/audio-player.vala \
	core/library.vala \
	core/mpris.vala \
	core/radio-station.vala \
	core/utils.vala \
	core/gradio.vala \
	ui/library-box.vala \
	ui/main-window.vala \
	ui/mini-player.vala \
	ui/player-toolbar.vala \
	ui/release-notes-window.vala \
	ui/settings-window.vala \
	ui/station-editor-dialog.vala \
	ui/discoverbox/discover-box.vala \
	ui/discoverbox/discover-box-sidebar.vala \
	ui/discoverbox/discover-box-sidebar-tile.vala \
	ui/discoverbox/discover-box-sidebar-row.vala \
	ui/stationsview/stations-view.vala \
	ui/stationsview/stations-view-button.vala \
	ui/stationsview/stations-view-grid-item.vala \
	ui/stationsview/stations-view-list-item.vala

gradio_CFLAGS = \
	-DVERSION=\"$(VERSION)\" \
	-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\" \
	-DDATA_DIRECTORY=\"$(datadir)/gradio\" \
	-DLOCALEDIR=\"$(datadir)/locale\" \
	-w \
	$(GRADIO_CFLAGS)


gradio_VALAFLAGS = \
	--enable-experimental \
	--target-glib $(GLIB_REQUIRED) \
	--pkg posix \
	--pkg gtk+-3.0 \
	--pkg gstreamer-pbutils-1.0 \
	--pkg gstreamer-1.0 \
	--pkg json-glib-1.0 \
	--pkg libsoup-2.4 \
	--pkg webkit2gtk-4.0 \
	--gresources $(gresource_file)

gradio_LDADD = \
	$(GRADIO_LIBS)

CLEANFILES = \
	$(patsubst %.vala,%.c,$(filter %.vala, $(SOURCES))) \
	*_vala.stamp

-include $(top_srcdir)/git.mk
