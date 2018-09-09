i18n = import('i18n')
gnome_module = import('gnome')

# Translate and install appdata #
appdata_conf = configuration_data()
appdata_conf.set('appid', application_id)
i18n.merge_file ('appdata-file',
  input: configure_file(
    input: files('de.haeckerfelix.Gradio.appdata.xml.in'),
    output: 'de.haeckerfelix.Gradio.appdata.xml.in',
    configuration: appdata_conf
  ),
  output: '@0@.appdata.xml'.format(application_id),
  po_dir: podir,
  install: true,
  install_dir: join_paths (datadir, 'metainfo')
)



# Translate and install desktop file #
desktop_conf = configuration_data()
desktop_conf.set('icon', application_id)
i18n.merge_file ('desktop-file',
  type: 'desktop',
  input: configure_file(
    input: files('de.haeckerfelix.Gradio.desktop.in'),
    output: 'de.haeckerfelix.Gradio.desktop.in',
    configuration: desktop_conf
  ),
  output: '@0@.desktop'.format(application_id),
  po_dir: podir,
  install: true,
  install_dir: join_paths (datadir, 'applications')
)


# Gschema / Settings #
install_data('de.haeckerfelix.Gradio.gschema.xml', install_dir: join_paths(datadir, 'glib-2.0', 'schemas'))


# DBUS service #
configure_file(
  input: 'de.haeckerfelix.Gradio.service.in',
  output: '@0@.service'.format(application_id),
  configuration: gradio_conf,
  install_dir: join_paths(datadir,'dbus-1', 'services')
)


# Icons #
icondir = join_paths(get_option('datadir'), 'icons', 'hicolor')
icon_sizes = ['16x16', '24x24', '32x32', '48x48', '256x256', '512x512']

foreach size : icon_sizes
	install_data('icons/hicolor/@0@/apps/de.haeckerfelix.gradio.png'.format(size), install_dir : join_paths(icondir, size, 'apps'))
endforeach

install_data('icons/hicolor/scalable/apps/de.haeckerfelix.gradio.svg', install_dir : 'share/icons/hicolor/scalable/apps')
install_data('icons/hicolor/scalable/apps/de.haeckerfelix.gradio-symbolic.svg', install_dir : 'share/icons/hicolor/symbolic/apps')


# Compile Gschema #
meson.add_install_script('../build-aux/compile-gschema.py')