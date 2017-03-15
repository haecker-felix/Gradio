project('gradio', ['vala', 'C'],
        version : '0.3.1',
        meson_version : '>= 0.36.0',
        license : 'GPL3',
        default_options: [
          'c_std=gnu11',
          'b_lundef=false',
        ])

# Used in config.h
LOCALE_DIR = join_paths(get_option('prefix'), get_option('localedir'))
LIB_DIR = join_paths(get_option('prefix'), get_option('libdir'))
DATA_DIR = join_paths(get_option('prefix'), get_option('datadir'))

meson.add_install_script('meson_post_install.sh')


subdir('src')
subdir('data')
subdir('po')

