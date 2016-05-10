include(ParseArguments)
find_package(Valadoc REQUIRED)

macro(valadoc target outdir)
	parse_arguments(ARGS "PACKAGES;OPTIONS;CUSTOM_VAPIS" "" ${ARGN})
	set(vala_pkg_opts "")
	foreach(pkg ${ARGS_PACKAGES})
		list(APPEND vala_pkg_opts "--pkg=${pkg}")
	endforeach(pkg ${ARGS_PACKAGES})

	set(vapi_dir_opts "")
	foreach(src ${ARGS_CUSTOM_VAPIS})
		get_filename_component(pkg ${src} NAME_WE)
		list(APPEND vala_pkg_opts "--pkg=${pkg}")
		
		get_filename_component(path ${src} PATH)
		list(APPEND vapi_dir_opts "--vapidir=${path}")
	endforeach(src ${ARGS_DEFAULT_ARGS})
	list(REMOVE_DUPLICATES vapi_dir_opts)

	add_custom_command(TARGET ${target}
	COMMAND
		${VALADOC_EXECUTABLE}
	ARGS
		"--force"
		"-b" ${CMAKE_CURRENT_SOURCE_DIR}
		"-o" ${outdir}
		"--package-name=${CMAKE_PROJECT_NAME}"
		"--package-version=${PROJECT_VERSION}"
		${vala_pkg_opts}
		${vapi_dir_opts}
		${ARGS_OPTIONS}
		${in_files} 
	DEPENDS
		${in_files}
		${ARGS_CUSTOM_VAPIS}
	)
endmacro(valadoc)
