hicolor_icon16dir = $(datadir)/icons/hicolor/16x16/apps
hicolor_icon16_DATA = hicolor/16x16/apps/de.haeckerfelix.gradio.png
hicolor_icon32dir = $(datadir)/icons/hicolor/32x32/apps
hicolor_icon32_DATA = hicolor/32x32/apps/de.haeckerfelix.gradio.png
hicolor_icon48dir = $(datadir)/icons/hicolor/48x48/apps
hicolor_icon48_DATA = hicolor/48x48/apps/de.haeckerfelix.gradio.png
hicolor_icon128dir = $(datadir)/icons/hicolor/128x128/apps
hicolor_icon128_DATA = hicolor/128x128/apps/de.haeckerfelix.gradio.png
hicolor_icon192dir = $(datadir)/icons/hicolor/192x192/apps
hicolor_icon192_DATA = hicolor/192x192/apps/de.haeckerfelix.gradio.png
hicolor_iconscalabledir = $(datadir)/icons/hicolor/scalable/apps
hicolor_iconscalable_DATA = hicolor/scalable/apps/de.haeckerfelix.gradio-symbolic.svg
hicolor_icon_files = \
	$(hicolor_icon16_DATA) \
	$(hicolor_icon32_DATA) \
	$(hicolor_icon48_DATA) \
	$(hicolor_icon128_DATA) \
	$(hicolor_icon192_DATA) \
	$(hicolor_iconscalable_DATA) \
	hicolor/scalable/categories/globe-symbolic.svg \
	hicolor/scalable/categories/language-symbolic.svg \
	hicolor/scalable/categories/map-marker-symbolic.svg \
	hicolor/scalable/categories/tags-symbolic.svg \
	hicolor/de.haeckerfelix.gradio.svg

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
