# Adatped from:
# https://gitlab.gnome.org/danigm/fractal/blob/6e2911f9d2353c99a18a6c19fab7f903c4bbb431/meson.build

project(
  'gradio', 'rust',
  version: '7.99.0',
  license: 'GPLv3',
)

if get_option('profile') == 'development'
  profile = 'Devel'
  name_suffix = ' (Development)'
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD').stdout().strip()
  if vcs_tag == ''
    version_suffix = '-devel'
  else
    version_suffix = '-@0@'.format (vcs_tag)
  endif
else
  profile = ''
  name_suffix = ''
  version_suffix = ''
endif

application_id = 'de.haeckerfelix.Gradio@0@'.format(profile)

gradio_version = meson.project_version()
version_array = gradio_version.split('.')
gradio_major_version = version_array[0].to_int()
gradio_minor_version = version_array[1].to_int()
gradio_version_micro = version_array[2].to_int()

gradio_prefix = get_option('prefix')
gradio_bindir = join_paths(gradio_prefix, get_option('bindir'))
gradio_localedir = join_paths(gradio_prefix, get_option('localedir'))

datadir = get_option('datadir')

i18n = import('i18n')

podir = join_paths (meson.source_root (), 'po')

subdir('po')
subdir('data')

cargo = find_program('cargo', required: false)
gresource = find_program('glib-compile-resources', required: false)
cargo_vendor = find_program('cargo-vendor', required: false)
cargo_script = find_program('build-aux/cargo.sh')
grabber = find_program('build-aux/grabber.sh')
cargo_release = find_program('build-aux/release.sh')

c = run_command(grabber)
sources = c.stdout().strip().split('\n')

cargo_release = custom_target('cargo-build',
                        build_by_default: true,
                        input: sources,
                        output: ['gradio'],
                        install: true,
                        install_dir: gradio_bindir,
                        console: true,
                        command: [cargo_script,
                                  '@CURRENT_SOURCE_DIR@',
                                  '@OUTPUT@',
                                  gradio_localedir,
                                  application_id,
                                  name_suffix,
                                  gradio_version + version_suffix,
                                  profile
                                 ])

run_target('release', command: ['build-aux/release.sh',
                                meson.project_name() + '-' + gradio_version
                               ])

meson.add_install_script('build-aux/meson_post_install.py')
