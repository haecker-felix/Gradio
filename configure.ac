AC_PREREQ([2.63])
AC_INIT([Gradio], [5.0.0b2], [https://github.com/haecker-felix/gradio/issues],
        [gradio], [https://github.com/haecker-felix/gradio/])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE

AM_PROG_VALAC([0.24])
AM_PROG_CC_C_O

# GResource
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

# GSettings support
GLIB_GSETTINGS


dnl ###########################################################################
dnl Dependencies
dnl ###########################################################################

GLIB_REQUIRED=2.40.0
GTK_REQUIRED=3.14

PKG_CHECK_MODULES(GRADIO, [
  glib-2.0 >= $GLIB_REQUIRED
  gtk+-3.0 >= $GTK_REQUIRED
  gstreamer-1.0
  gstreamer-pbutils-1.0
  gstreamer-plugins-base-1.0
  json-glib-1.0
  gio-2.0
  libsoup-2.4
  webkit2gtk-4.0
])

AC_SUBST([GLIB_REQUIRED])

AC_PATH_PROG([DESKTOP_FILE_VALIDATE], [desktop-file-validate], [/bin/true])

dnl ###########################################################################
dnl Internationalization
dnl ###########################################################################

IT_PROG_INTLTOOL([0.50])
AC_SUBST(GETTEXT_PACKAGE, gradio)


dnl ###########################################################################
dnl Files to generate
dnl ###########################################################################

AC_CONFIG_FILES([
Makefile
po/Makefile.in
data/Makefile
data/icons/Makefile
data/icons/hicolor/Makefile
src/Makefile
])
AC_OUTPUT
