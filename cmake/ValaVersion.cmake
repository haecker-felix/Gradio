##
# Copyright (C) 2014 Raster Software Vigo
# Autovala is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Autovala is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright (C) 2013, Valama development team
#
# Copyright 2009-2010 Jakob Westhoff All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#	1. Redistributions of source code must retain the above copyright notice,
#	   this list of conditions and the following disclaimer.
# 
#	2. Redistributions in binary form must reproduce the above copyright notice,
#	   this list of conditions and the following disclaimer in the documentation
#	   and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY JAKOB WESTHOFF ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL JAKOB WESTHOFF OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied, of Jakob Westhoff
##

include(ParseArguments)
find_package(Vala REQUIRED)

##
# Ensure a certain valac version is available
#
# The initial argument is the version to check for
# 
# It may be followed by a optional parameter to specifiy a version range. The
# following options are valid:
# 
# EXACT
#   Vala needs to be available in the exact version given
# 
# MINIMUM
#   The provided version is the minimum version. Therefore Vala needs to be
#   available in the given version or any higher version
#
# MAXIMUM
#   The provided version is the maximum. Therefore Vala needs to be available
#   in the given version or any version older than this
#
# If no option is specified the version will be treated as a minimal version.
##
macro(ensure_vala_version ensure_version)

	if (USE_VALA_BINARY)
		message(STATUS "Forced use of vala binary ${USE_VALA_BINARY}")
		set(VALA_EXECUTABLE ${USE_VALA_BINARY})
	else (USE_VALA_BINARY)

		message(STATUS "checking for Vala version of valac-${ensure_version}")
	
		unset(version_accepted)
		execute_process(COMMAND "valac-${ensure_version}" "--version"
			OUTPUT_VARIABLE "VALA_VERSION" OUTPUT_STRIP_TRAILING_WHITESPACE)
		if (NOT VALA_VERSION)
	
			find_program(VALA_EXECUTABLE "valac")
	
			# If the specific version asked for this project is not found,
			# try to use the one pointed by the valac link
	
			parse_arguments(ARGS "" "MINIMUM;MAXIMUM;EXACT" ${ARGN})
			set(compare_message "")
			set(error_message "")
			if(ARGS_MINIMUM)
				set(compare_message "a minimum ")
				set(error_message "or greater ")
			elseif(ARGS_MAXIMUM)
				set(compare_message "a maximum ")
				set(error_message "or less ")
			endif(ARGS_MINIMUM)
	
			message(STATUS "checking for ${compare_message}Vala version of ${ensure_version}" )
	
			execute_process(COMMAND ${VALA_EXECUTABLE} "--version"
				OUTPUT_VARIABLE "VALA_VERSION" OUTPUT_STRIP_TRAILING_WHITESPACE)
		else(NOT VALA_VERSION)
			set(VALA_EXECUTABLE "valac-${ensure_version}")
		endif(NOT VALA_VERSION)

		# this code allows to identify development versions as the right version
		# e.g. 0.19.1 -> 0.20 ; 0.20.1 -> 0.20 ;
		# But this code seems to not be fine 0.24.0.2-2235 -> 0.26
		# Thanks to Yannick Inizan
		string(REPLACE "Vala" "" "VALA_VERSION" ${VALA_VERSION})
		string(STRIP ${VALA_VERSION} "VALA_VERSION")
		string(REPLACE "." ";" VALA_LIST "${VALA_VERSION}")
		list(GET VALA_LIST 0 maj_ver)
		list(GET VALA_LIST 1 min_ver)
		list(GET VALA_LIST 2 rev_ver)
		math(EXPR is_odd "${min_ver} % 2")
		list(LENGTH VALA_LIST len)
		#if((${is_odd} EQUAL 1))
		#	math(EXPR min_ver "${min_ver} + 1")
		#elseif(len GREATER 3)
		#	math(EXPR min_ver "${min_ver} + 2")
		#endif()

		set(VALA_SVERSION "${maj_ver}.${min_ver}" CACHE INTERNAL "")

		# MINIMUM is the default if no option is specified
		if(ARGS_EXACT)
			if(${VALA_SVERSION} VERSION_EQUAL ${ensure_version} )
				set(version_accepted TRUE)
			endif(${VALA_SVERSION} VERSION_EQUAL ${ensure_version})
		elseif(ARGS_MAXIMUM)
			if(${VALA_SVERSION} VERSION_LESS ${ensure_version} OR ${VALA_SVERSION} VERSION_EQUAL ${ensure_version})
				set(version_accepted TRUE)
			endif(${VALA_SVERSION} VERSION_LESS ${ensure_version} OR ${VALA_SVERSION} VERSION_EQUAL ${ensure_version})
		else(ARGS_MAXIMUM)
			if(${VALA_SVERSION} VERSION_GREATER ${ensure_version} OR ${VALA_SVERSION} VERSION_EQUAL ${ensure_version})
				set(version_accepted TRUE)
			endif(${VALA_SVERSION} VERSION_GREATER ${ensure_version} OR ${VALA_SVERSION} VERSION_EQUAL ${ensure_version})
		endif(ARGS_EXACT)
	
		if (NOT version_accepted)
			message(FATAL_ERROR 
				"Vala version ${ensure_version} ${error_message}is required."
			)
		endif(NOT version_accepted)
	
		message(STATUS
			"  found Vala, version ${VALA_SVERSION}"
		)
	endif(USE_VALA_BINARY)
endmacro(ensure_vala_version)
