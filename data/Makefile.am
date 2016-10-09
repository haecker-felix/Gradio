SUBDIRS = icons

gsettings_SCHEMAS = schemas/de.haecker-felix.gradio.gschema.xml

.PRECIOUS: $(gsettings_SCHEMAS)

@GSETTINGS_RULES@

cssdir = $(pkgdatadir)
css_DATA = ui/style/gradio.css

gresource_file = gradio.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))

desktopdir = $(datadir)/applications
desktop_in_files = de.haeckerfelix.gradio.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@


EXTRA_DIST = \
	$(appstream_in_files) \
	$(gsettings_SCHEMAS) \
	$(desktop_in_files) \
	$(css_DATA) \
	$(gresource_file)

CLEANFILES = \
	$(appstream_XML) \
	$(desktop_DATA)

check-local: $(desktop_DATA) \
	$(DESKTOP_FILE_VALIDATE) $(desktop_DATA)

DISTCHECK_CONFIGURE_FLAGS = --enable-appdata-check

-include $(top_srcdir)/git.mk
