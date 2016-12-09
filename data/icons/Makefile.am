icondir = $(datadir)/icons

nobase_icon_DATA = \
	hicolor/192x192/apps/de.haeckerfelix.gradio.png \
	hicolor/128x128/apps/de.haeckerfelix.gradio.png \
	hicolor/64x64/apps/de.haeckerfelix.gradio.png \
	hicolor/48x48/apps/de.haeckerfelix.gradio.png \
	hicolor/32x32/apps/de.haeckerfelix.gradio.png \
	hicolor/16x16/apps/de.haeckerfelix.gradio.png \
	hicolor/symbolic/apps/de.haeckerfelix.gradio-symbolic.svg \
	hicolor/scalable/categories/globe-symbolic.svg \
	hicolor/scalable/categories/language-symbolic.svg \
	hicolor/scalable/categories/map-marker-symbolic.svg \
	hicolor/scalable/categories/tags-symbolic.svg \
	$(NULL)

EXTRA_DIST = $(nobase_icon_DATA)

gtk_update_icon_cache = gtk-update-icon-cache -f -t $(datadir)/icons/hicolor

install-data-hook: update-icon-cache
uninstall-hook: update-icon-cache
update-icon-cache:
	@-if test -z "$(DESTDIR)"; then \
		echo "Updating Gtk icon cache."; \
		$(gtk_update_icon_cache); \
	else \
		echo "*** Icon cache not updated.  After (un)install, run this:"; \
		echo "***   $(gtk_update_icon_cache)"; \
	fi

-include $(top_srcdir)/git.mk
