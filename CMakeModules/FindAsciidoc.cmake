# - Find asciidoc tool
# The module defines the following variables:
#  ASCIIDOC_EXECUTABLE: the full path to the asciidoc tool.
#  ASCIIDOC_A2X_EXECUTABLE: the full path to the a2x tool.
#  ASCIIDOC_FOUND: True if asciidoc has been found.
#  ASCIIDOC_VERSION_STRING: the version of asciidoc found
#
# Next variables are used by soma macroes:
#  ASCIIDOC_ARGS: Additional argumets supplied to asciidoc executable
#  ASCIIDOC_A2X_ARGS: Additional argumets supplied to a2x executable
#
# It also provides the following macros:
#========= Copyright =================================================#
#  Copyright (C) 2014 Alexander Golubev (Fat-Zer) <fatzer2@gmail.com>
#
#  This file is dual licensed. You may use and distribute it providing
#  that you comply EITHER with the terms of the 3-clause BSD license, 
#  OR the GPLv2+ license. It is not necessary to comply with both 
#  licenses, only one.
#=====================================================================#


find_program( ASCIIDOC_EXECUTABLE asciidoc )
find_program( ASCIIDOC_A2X_EXECUTABLE a2x )

if( ASCIIDOC_EXECUTABLE )
    execute_process( COMMAND ${ASCIIDOC_EXECUTABLE} --version
        OUTPUT_VARIABLE _asciidoc_version
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX REPLACE "^asciidoc ([0-9\\.]+\\S*).*" "\\1"
        ASCIIDOC_VERSION_STRING "${_asciidoc_version}")

    unset(_asciidoc_version)
endif()

mark_as_advanced(
    ASCIIDOC_EXECUTABLE
    ASCIIDOC_A2X_EXECUTABLE
)

find_package( PackageHandleStandardArgs )

find_package_handle_standard_args( Asciidoc
    REQUIRED_VARS ASCIIDOC_EXECUTABLE ASCIIDOC_A2X_EXECUTABLE
    VERSION_VAR ASCIIDOC_VERSION_STRING
)

function(_asciidoc_unique_target_name _name _unique_name)
    set( propertyName "_asciidoc_unique_counter_${_name}" )
    get_property( currentCounter GLOBAL PROPERTY "${propertyName}" )
    if( NOT currentCounter )
        set(${_unique_name} "${_name}" PARENT_SCOPE)
        set( currentCounter 1 )
    else( )
        set(${_unique_name} "${_name}_${currentCounter}" PARENT_SCOPE)
        math( EXPR currentCounter "${currentCounter} + 1" )
    endif( )
    set_property( GLOBAL PROPERTY ${propertyName} ${currentCounter} )
endfunction()

function( _asciidoc_switch_format_settings _format _parser _extension _extra_install)
    if(     ${_format} STREQUAL "html" )
        set( ${_parser} asciidoc PARENT_SCOPE )
        set( ${_extension} html  PARENT_SCOPE )
        set( ${_extra_install} ON PARENT_SCOPE )
    elseif( ${_format} STREQUAL "xhtml" )
        set( ${_parser} asciidoc PARENT_SCOPE )
        set( ${_extension} html  PARENT_SCOPE )
        set( ${_extra_install} ON PARENT_SCOPE )
    elseif( ${_format} STREQUAL "wordpress" )
        set( ${_parser} asciidoc PARENT_SCOPE )
        set( ${_extension} html  PARENT_SCOPE )
        set( ${_extra_install} ON PARENT_SCOPE )
    elseif( ${_format} STREQUAL "html4" )
        set( ${_parser} asciidoc PARENT_SCOPE )
        set( ${_extension} html  PARENT_SCOPE )
        set( ${_extra_install} ON PARENT_SCOPE )
    elseif( ${_format} STREQUAL "latex" )
        set( ${_parser} asciidoc PARENT_SCOPE )
        set( ${_extension} tex   PARENT_SCOPE )
        set( ${_extra_install} ON PARENT_SCOPE )
    elseif( ${_format} STREQUAL "docbook" )
        set( ${_parser} asciidoc   PARENT_SCOPE )
        set( ${_extension} docbook PARENT_SCOPE )
        set( ${_extra_install} ON PARENT_SCOPE )
    elseif( ${_format} STREQUAL "docbook45" )
        set( ${_parser}    asciidoc PARENT_SCOPE )
        set( ${_extension} docbook  PARENT_SCOPE )
        set( ${_extra_install} ON PARENT_SCOPE )
    elseif( ${_format} STREQUAL "dvi" )
        set( ${_parser}    a2x PARENT_SCOPE )
        set( ${_extension} dvi PARENT_SCOPE )
    elseif( ${_format} STREQUAL "pdf" )
        set( ${_parser}    a2x PARENT_SCOPE )
        set( ${_extension} pdf  PARENT_SCOPE )
#    elseif( ${_format} STREQUAL "htmlhelp" )
#        set( ${_parser}    a2x  PARENT_SCOPE )
#        set( ${_extension} html PARENT_SCOPE )
#        set( ${_extra_install} ON PARENT_SCOPE )
    elseif( ${_format} STREQUAL "epub" )
        set( ${_parser}    a2x  PARENT_SCOPE )
        set( ${_extension} epub PARENT_SCOPE )
        # man output extentiont depends on file content (the man page number)
#    elseif( ${_format} STREQUAL "manpage" )
#        set( ${_parser}    a2x PARENT_SCOPE )
#        set( ${_extension}     PARENT_SCOPE )
    elseif( ${_format} STREQUAL "ps" )
        set( ${_parser}    a2x PARENT_SCOPE )
        set( ${_extension} ps  PARENT_SCOPE )
    elseif( ${_format} STREQUAL "text" )
        set( ${_parser}    a2x  PARENT_SCOPE )
        set( ${_extension} text PARENT_SCOPE )
    else( )
        message( FATAL_ERROR "unknown FORMAT: \"${_format}\"" )
    endif( )
endfunction()

function( build_asciidoc _adoc_file )
    set(options ALL)
    set(oneValueArgs DESTINATION FORMAT LANG OUTPUT)
    set(multiValueArgs EXTRA )
    cmake_parse_arguments( _parsed "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if( NOT _parsed_FORMAT )
        message( FATAL_ERROR "FORMAT for asciidoc \"${_adoc_file}\" not specified" )
    endif(  )

    _asciidoc_switch_format_settings (${_parsed_FORMAT} _asciidoc_parser _output_extension _install_extras)

    get_filename_component (_adoc_name ${_adoc_file} NAME)
    string( REGEX REPLACE "^(.+)(\\.[^.]+)$" "\\1" _adoc_basename ${_adoc_name})

    if( _parsed_OUTPUT )
        if( IS_ABSOLUTE _parsed_OUTPUT )
            set( _output ${_parsed_OUTPUT} )
        else( )
            set( _output ${CMAKE_CURRENT_BINARY_DIR}/${_parsed_OUTPUT} )
        endif( )
    else( )
        if( _output_extension )
            set( _output ${CMAKE_CURRENT_BINARY_DIR}/${_adoc_basename}.${_output_extension} )
        else( )
            set( _output ${CMAKE_CURRENT_BINARY_DIR}/${_adoc_basename} )
        endif ()
    endif( )

    get_filename_component( _output_dir ${_output} DIRECTORY )

    foreach (_extra ${_parsed_EXTRA})
        get_filename_component( _extra_name ${_extra} NAME)
        file( COPY ${_extra} DESTINATION "${_output_dir}/" )
        file( GLOB_RECURSE _current_extra_files
            FOLLOW_SYMLINKS "${_output_dir}/${_extra}/*" )

        list( APPEND _extra_files ${_current_extra_files} )
    endforeach (_extra _parsed_EXTRA)

    if ( _asciidoc_parser STREQUAL "asciidoc")
        if( _parsed_LANG )
            list( APPEND _asciidoc_args -l ${_parsed_LANG} )
        endif( )
        list( APPEND _asciidoc_args ${ASCIIDOC_ARGS} )
        add_custom_command( OUTPUT ${_output}
            COMMAND "${ASCIIDOC_EXECUTABLE}" -b "${_parsed_FORMAT}" ${_asciidoc_args}
                -o "${_output}" "${_adoc_file}"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            DEPENDS ${_adoc_file} ${_extra_files}
        )
    elseif( _asciidoc_parser STREQUAL "a2x")
        # a2x doesn't support custom output naming so check if output conforms to it
        if (NOT _output STREQUAL "${_output_dir}/${_adoc_basename}.${_output_extension}")
             message( FATAL_ERROR "a2x doesn't support custom OUTPUT option" )
        endif( )

        if( _parsed_LANG )
            list( APPEND _a2x_args -a "lang=${_parsed_LANG}" )
        endif( )

        if( ASCIIDOC_A2X_${_parsed_FORMAT}_ARGS )
            list( APPEND _a2x_args ${ASCIIDOC_A2X_${_parsed_FORMAT}_ARGS} )
        endif( )
        list( APPEND _a2x_args ${ASCIIDOC_A2X_ARGS} )
        add_custom_command( OUTPUT ${_output}
            COMMAND "${ASCIIDOC_A2X_EXECUTABLE}" -f "${_parsed_FORMAT}"
                ${_a2x_args} -D "${_output_dir}" "${_adoc_file}"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            DEPENDS ${_adoc_file} ${_extra_files}
        )
    else( )
        message( FATAL_ERROR "Unsupported asciidoc parser util \"${_asciidoc_parser}\"" )
    endif( )

    if( _parsed_DESTINATION )
        install( FILES ${_output} DESTINATION ${_parsed_DESTINATION} )

        if( _install_extras )
            foreach( _extra ${_parsed_EXTRA} )
                get_filename_component( _extra_path ${_extra} ABSOLUTE)
                if( IS_DIRECTORY "${_extra_path}" )
                    install( DIRECTORY ${_extra} DESTINATION ${_parsed_DESTINATION} )
                else( )
                    install( FILES ${_extra} DESTINATION ${_parsed_DESTINATION} )
                endif( )
            endforeach( )
        endif( )
    endif( _parsed_DESTINATION )

    _asciidoc_unique_target_name( "asciidoc_${_adoc_basename}" _unique_target )

   if( _parsed_ALL)
      add_custom_target("${_unique_target}" ALL DEPENDS "${_output}")
   else()
      add_custom_target("${_unique_target}" DEPENDS "${_output}")
   endif()

   if( NOT TARGET asciidoc )
       add_custom_target( asciidoc )
   endif( )

   add_dependencies( asciidoc "${_unique_target}" )

endfunction()
