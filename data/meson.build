gnome_module = import('gnome')

resources = gnome_module.compile_resources('gradio-resources', 'de.haeckerfelix.gradio.gresource.xml', source_dir : '.')

msgfmt = find_program('msgfmt')
podir = join_paths(meson.source_root(), 'po')
datadir = get_option('datadir')

custom_target('desktop-file',
    input : 'de.haeckerfelix.gradio.desktop.in',
    output : 'de.haeckerfelix.gradio.desktop',
    command : [msgfmt, '--desktop', '--template', '@INPUT@', '-d', podir, '-o', '@OUTPUT@'],
    install : true,
    install_dir : join_paths(datadir, 'applications'))

custom_target('appdata-file',
    input : 'de.haeckerfelix.gradio.appdata.xml.in',
    output : 'de.haeckerfelix.gradio.appdata.xml',
    command : [msgfmt, '--xml', '--template', '@INPUT@', '-d', podir, '-o', '@OUTPUT@'],
    install : true,
    install_dir : join_paths(datadir, 'appdata'))

icondir = join_paths(datadir, 'icons', 'hicolor')
icon_sizes = ['16x16', '24x24', '32x32', '48x48', '256x256', '512x512']

foreach size : icon_sizes
  install_data('icons/hicolor/@0@/apps/de.haeckerfelix.gradio.png'.format(size),
               install_dir : join_paths(icondir, size, 'apps'))
endforeach

install_data('icons/hicolor/scalable/apps/de.haeckerfelix.gradio.svg',
             install_dir : 'share/icons/hicolor/scalable/apps')

install_data('icons/hicolor/scalable/apps/de.haeckerfelix.gradio-symbolic.svg',
             install_dir : 'share/icons/hicolor/symbolic/apps')

install_data('de.haeckerfelix.gradio.gschema.xml',
             install_dir : join_paths(datadir, 'glib-2.0/schemas/'))

