#    CMakeLists.txt
#
#    Copyright (C) 2016 Felix Häcker <haecker.felix1207@gmail.com>
#
#    Gradio is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Gradio is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Gradio.  If not, see <http://www.gnu.org/licenses/>.
#

cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)
project (gradio)
enable_testing ()


# Project info
set (EXEC_NAME "gradio")
set (APP_NAME "Gradio")
set (VERSION "1.01")
set (VERSION_INFO "Alpha")
set (COPYRIGHT "Copyright 2016 Felix Häcker")
set (DESCRIPTION "Generate QR Codes")
set (RELEASE_NAME "${DESCRIPTION}")
set (WEBSITE "http://haecker-felix.github.io/gradio/")


# base bits
include (GNUInstallDirs)
set (DATADIR "${CMAKE_INSTALL_FULL_DATAROOTDIR}")
set (PKGDATADIR "${DATADIR}/${CMAKE_PROJECT_NAME}")
set (GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}")

list (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")

set (CPACK_PACKAGE_VERSION "${VERSION}")
set (CPACK_SOURCE_GENERATOR "TGZ")
set (CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
set (CPACK_SOURCE_IGNORE_FILES "/build/;/.git/;/.gitignore/~$;${CPACK_SOURCE_IGNORE_FILES}")

include (CPack)
add_custom_target (dist COMMAND "$CMAKE_MAKE_PROGRAM} package_source")

set(COMPILE_OPTIONS_VALA ${COMPILE_OPTIONS_VALA} --pkg gstreamer-1.0 json-glib-1.0 gio-2.0 gee-0.8)

### PKGCONFIG ###
find_package ( PkgConfig REQUIRED )
pkg_check_modules ( DEPS
	REQUIRED glib-2.0
	REQUIRED gtk+-3.0>=3.14
	REQUIRED gstreamer-1.0
	REQUIRED json-glib-1.0
	REQUIRED gio-2.0
	REQUIRED gee-0.8
)
include_directories ( ${DEPS_INCLUDE_DIRS} )
link_libraries ( ${DEPS_LIBRARIES} )
link_directories ( ${DEPS_LIBRARY_DIRS} )
add_definitions ( ${DEPS_CFLAGS} )

### TRANSLATION ###
set (GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}")
add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
add_subdirectory (po)


### GRESOURCES ###
include ( GResource )
set ( GRESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/data/gradio.gresource.xml )
glib_compile_resources ( RESOURCE_FILE SOURCE data/gradio.gresource.xml )

#GSettings
include(GSettings)
add_schema("data/de.haecker-felix.gradio.gschema.xml")

### VALA FILES ###
find_package ( Vala REQUIRED )
include ( ValaVersion )
ensure_vala_version ( "0.22" MINIMUM )

### Compile ###
if (CMAKE_BUILD_TYPE MATCHES Debug)
	set (VALA_FLAGS "--debug")
endif (CMAKE_BUILD_TYPE MATCHES Debug)
include ( ValaPrecompile )
vala_precompile (
VALA_C ${EXEC_NAME}
	src/Gradio.vala
	src/Widgets/MainWindow.vala
	src/Widgets/DiscoverBox.vala
	src/Widgets/LibraryBox.vala
	src/Widgets/PlayerToolbar.vala
	src/Widgets/ListItem.vala
	src/Widgets/SettingsDialog.vala
	src/AudioPlayer.vala
	src/RadioStation.vala
	src/Util.vala
	src/DataProvider.vala
	src/Library.vala
#CUSTOM_VAPIS
#	vapi/libqrencode.vapi
PACKAGES
	gtk+-3.0
	glib-2.0
	gstreamer-1.0
	json-glib-1.0
	gio-2.0
	gee-0.8
OPTIONS
	--thread
	--target-glib=2.38
	--gresources ${GRESOURCES}
	${VALA_FLAGS}
)

# Source files definition
set ( SRC_FILES ${RESOURCE_FILE} ${VALA_C} )
add_executable ( gradio ${SRC_FILES} )
target_link_libraries ( gradio ${DEPS_LIBRARIES} m )

# Install
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/gradio.desktop DESTINATION ${DATADIR}/applications/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/32/gradio.png DESTINATION share/icons/hicolor/32x32/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/48/gradio.png DESTINATION share/icons/hicolor/48x48/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/64/gradio.png DESTINATION share/icons/hicolor/64x64/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/128/gradio.png DESTINATION share/icons/hicolor/128x128/apps)
