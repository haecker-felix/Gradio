# Adatped from:
# https://gitlab.gnome.org/World/podcasts/blob/master/meson.build

project(
  'gradio', 'rust',
  version: '8.0.0',
  license: 'GPLv3',
)

if get_option('profile') == 'development'
  profile = 'Devel'
  vcs_tag = run_command('git', 'rev-parse', '--short', 'HEAD').stdout().strip()
  if vcs_tag == ''
    version_suffix = '-devel'
  else
    version_suffix = '-@0@'.format (vcs_tag)
  endif
else
  profile = ''
  version_suffix = ''
endif

application_id = 'de.haeckerfelix.Gradio@0@'.format(profile)
i18n = import('i18n')

subdir('po')
podir = join_paths (meson.source_root (), 'po')

gradio_version = meson.project_version()
version_array = gradio_version.split('.')
gradio_major_version = version_array[0].to_int()
gradio_minor_version = version_array[1].to_int()
gradio_version_micro = version_array[2].to_int()

gradio_prefix = get_option('prefix')
gradio_bindir = join_paths(gradio_prefix, get_option('bindir'))
gradio_localedir = join_paths(gradio_prefix, get_option('localedir'))

gradio_conf = configuration_data()
gradio_conf.set('appid', application_id)
gradio_conf.set('bindir', gradio_bindir)

datadir = get_option('datadir')
subdir('data')

cargo = find_program('cargo', required: false)
gresource = find_program('glib-compile-resources', required: false)
cargo_vendor = find_program('cargo-vendor', required: false)
cargo_script = find_program('build-aux/cargo.sh')

cargo_release = custom_target('cargo-build',
	build_always_stale: true,
	output: ['gradio'],
	install: true,
	install_dir: gradio_bindir,
	command: [cargo_script,
		'@CURRENT_SOURCE_DIR@',
		'@OUTPUT@',
		gradio_localedir,
		application_id,
		gradio_version + version_suffix,
		profile
		])

run_target('release', command: ['build-aux/release.sh', meson.project_name() + '-' + gradio_version])
