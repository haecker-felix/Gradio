i18n = import('i18n')
gnome_module = import('gnome')

# Compile Resources #
resources = gnome_module.compile_resources('gradio-resources', 'de.haeckerfelix.gradio.gresource.xml', source_dir : '.')


# Translate and install appdata and desktop file #
i18n.merge_file(
	input:  'de.haeckerfelix.gradio.desktop.in',
	output: 'de.haeckerfelix.gradio.desktop',
	po_dir: '../po/',
	type:   'desktop',
	install: true,
	install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
  input:  'de.haeckerfelix.gradio.appdata.xml.in',
  output: 'de.haeckerfelix.gradio.appdata.xml',
  po_dir: '../po/',
  type:   'xml',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'appdata')
)

# dbus service / search provider
dbusconf = configuration_data()
dbusconf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
configure_file(
  input: 'de.haeckerfelix.gradio.service.in',
  output: 'de.haeckerfelix.gradio.service',
  configuration: dbusconf,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'dbus-1', 'services'),
)

install_data('de.haeckerfelix.gradio.search-provider.ini',
  install_dir: join_paths(get_option('datadir'), 'gnome-shell', 'search-providers'),
)

# Icons #
icondir = join_paths(get_option('datadir'), 'icons', 'hicolor')
icon_sizes = ['16x16', '24x24', '32x32', '48x48', '256x256', '512x512']

foreach size : icon_sizes
	install_data('icons/hicolor/@0@/apps/de.haeckerfelix.gradio.png'.format(size), install_dir : join_paths(icondir, size, 'apps'))
endforeach

install_data('icons/hicolor/scalable/apps/de.haeckerfelix.gradio.svg', install_dir : 'share/icons/hicolor/scalable/apps')
install_data('icons/hicolor/scalable/apps/de.haeckerfelix.gradio-symbolic.svg', install_dir : 'share/icons/hicolor/symbolic/apps')


# Settings Schema #
install_data('de.haeckerfelix.gradio.gschema.xml', install_dir : join_paths(get_option('datadir'), 'glib-2.0/schemas/'))
