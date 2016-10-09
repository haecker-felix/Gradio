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
	main.vala \
	Data/SettingsManager.vala \
	Data/Codec.vala \
	Data/StationProvider.vala \
	Data/RadioBrowser.vala \
	Data/CategoryItemProvider.vala \
	Data/ImageProvider.vala \
	Widgets/DiscoverBox/DiscoverBox.vala \
	Widgets/DiscoverBox/DiscoverSidebar.vala \
	Widgets/DiscoverBox/CategoriesRow.vala \
	Widgets/DiscoverBox/SidebarTile.vala \
	Widgets/LibraryBox.vala \
	Widgets/PlayerToolbar.vala \
	Widgets/StationsView/ListItem.vala \
	Widgets/StationsView/GridItem.vala \
	Widgets/SettingsDialog.vala \
	Widgets/StationsView/StationsView.vala \
	Widgets/StationsView/StationsViewButton.vala \
	Widgets/StationEditorDialog.vala \
	Widgets/MiniPlayer.vala \
	Widgets/ReleaseNotesWindow.vala \
	AudioPlayer.vala \
	RadioStation.vala \
	Util.vala \
	Gradio.vala \
	Widgets/MainWindow.vala \
	Library.vala \
	MPRIS.vala

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
