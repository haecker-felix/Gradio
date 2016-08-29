# project name
project (gradio)

# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.6)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})
set (EXEC_NAME ${CMAKE_PROJECT_NAME})
set (ICON_NAME ${CMAKE_PROJECT_NAME})
set (APP_NAME "Gradio")
set (GENERIC_NAME "Internet Radio")
set (COMMENT "Listen to radio stations worldwide")
set (VERSION "4.0.1")
set (VERSION_INFO "Stable")

# where we install data directory (if we have any)
include (GNUInstallDirs)
set (CMAKE_INSTALL_PREFIX "/usr")
set (DATADIR ${CMAKE_INSTALL_PREFIX}/share)
set (PKG_DATADIR ${DATADIR}/${CMAKE_PROJECT_NAME})
set (DOLLAR "$")
set (ENCODING "UTF-8")

# Add 'make dist' command for creating release tarball
set (CPACK_PACKAGE_VERSION ${VERSION})
set (CPACK_SOURCE_GENERATOR "TGZ")
set (CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set (CPACK_SOURCE_IGNORE_FILES "/.git/;/.gitignore;/build/;/.bzr/;/.bzrignore;~$;${CPACK_SOURCE_IGNORE_FILES}")

include (CPack)
add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

# define variable for sources
set (SOURCE_LIST
	src/Data/Codec.vala
	src/Data/StationProvider.vala
	src/Data/RadioBrowser.vala
	src/Data/CategoryItemProvider.vala
	src/Widgets/DiscoverBox/DiscoverBox.vala
	src/Widgets/DiscoverBox/DiscoverSidebar.vala
	src/Widgets/DiscoverBox/CategoriesRow.vala
	src/Widgets/DiscoverBox/CategoryTile.vala
	src/Widgets/LibraryBox.vala
	src/Widgets/PlayerToolbar.vala
	src/Widgets/StationsView/ListItem.vala
	src/Widgets/StationsView/GridItem.vala
	src/Widgets/SettingsDialog.vala
	src/Widgets/StationsView/StationsView.vala
	src/Widgets/StationsView/StationsViewButton.vala
	src/Widgets/StationEditorDialog.vala
	src/Widgets/MiniPlayer.vala
	src/AudioPlayer.vala
	src/RadioStation.vala
	src/Util.vala
	src/Gradio.vala
	src/Widgets/MainWindow.vala
	src/Config.vala
	src/Library.vala
	src/MPRIS.vala
)

# Some configuration
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/src/Config.vala.cmake ${CMAKE_CURRENT_SOURCE_DIR}/src/Config.vala)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/data/de.haeckerfelix.gradio.desktop.in ${CMAKE_CURRENT_SOURCE_DIR}/data/de.haeckerfelix.gradio.desktop)

# Some definitions
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")

# custom command to update pot template files
set (_pot_file po/${PROJECT_NAME}.pot)
add_custom_command (OUTPUT ${_pot_file}
    COMMAND xgettext --output=${_pot_file} ${SOURCE_LIST} --from-code=${ENCODING}
    DEPENDS ${SOURCE_LIST}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Extract translatable messages to ${_pot_file}")

add_custom_target (pot_file ALL DEPENDS ${_pot_file})

include(InstallRequiredSystemLibraries)

# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)

# now let's actually check for the required dependencies
pkg_check_modules(DEPS REQUIRED
	glib-2.0
	gtk+-3.0>=3.18
	gstreamer-1.0
	gstreamer-pbutils-1.0
	gstreamer-plugins-base-1.0
	json-glib-1.0
	gio-2.0
	libsoup-2.4
)

set(NORMAL_CFLAGS ${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
set(NORMAL_LINK_DIRS ${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})
set(NORMAL_LIBRARIES ${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES})

add_definitions (${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
link_libraries (${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})

# gresources
include ( GResource )
set ( GRESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/data/gradio.gresource.xml )
glib_compile_resources ( RESOURCE_FILE SOURCE /data/gradio.gresource.xml )


# make sure we have vala
find_package(Vala REQUIRED)
# make sure we use vala
include(ValaVersion)
# make sure it's the desired version of vala
ensure_vala_version("0.16" MINIMUM)

add_definitions(-w) # Disable gcc warnings

# files we want to compile
include(ValaPrecompile)
vala_precompile(VALA_C ${EXEC_NAME}
    ${SOURCE_LIST}

# tell what libraries to use when compiling
PACKAGES
	glib-2.0
	gtk+-3.0
	gstreamer-1.0
	json-glib-1.0
	gio-2.0
	libsoup-2.4
	gstreamer-pbutils-1.0
OPTIONS
	--thread
	--target-glib=2.38
	--enable-experimental
	--gresources ${GRESOURCES}
	${VALA_FLAGS}
)

# tell cmake what to call the executable we just made
set ( SRC_FILES ${RESOURCE_FILE} ${VALA_C} )
add_executable(${EXEC_NAME} ${SRC_FILES})
target_link_libraries ( gradio ${DEPS_LIBRARIES} m )

# install the binaries we just made
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

include_directories(${CMAKE_BINARY_DIR}/src)

add_subdirectory (schemas)
add_subdirectory (po)

# install our .desktop file so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/de.haeckerfelix.gradio.desktop DESTINATION ${DATADIR}/applications)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/style/style.css DESTINATION ${PKG_DATADIR}/style)
install (DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/ DESTINATION ${DATADIR}/icons/hicolor)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/gradio.svg DESTINATION ${DATADIR}/pixmaps)

# uninstall target
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

