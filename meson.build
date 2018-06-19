project('gradio', 'rust', license: 'GPLv3')

i18n = import('i18n')

subdir('data')
subdir('po')


gradio_prefix = get_option('prefix')
gradio_bindir = join_paths(gradio_prefix, get_option('bindir'))

cargo = find_program('cargo', required: true)
cargo_script = find_program('build-aux/cargo.sh')

cargo_release = custom_target('cargo-build',
			build_by_default: true,
                        build_always: true,
                        output: ['gradio'],
                        install: true,
                        install_dir: gradio_bindir,
                        command: [cargo_script, '@CURRENT_SOURCE_DIR@', '@OUTPUT@'])

meson.add_install_script('build-aux/meson_post_install.sh')