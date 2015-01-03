# - Find po4a tools
# The module defines the following variables:
#  PO4A_EXECUTABLE: the full path to the po4a tool.
#  PO4A_TRANSLATE_EXECUTABLE: the full path to the po4a-translate tool.
#  PO4A_UPDATEPO_EXECUTABLE: the full path to the po4a-updatepo tool.
#  PO4A_BUILD_EXECUTABLE: the full path to the po4a-build tool. (Not mandatory)
#  PO4A_GETTEXTIZE_EXECUTABLE: the full path to the po4a-gettextize tool. (Not mandatory)
#  PO4A_NORMALIZE_EXECUTABLE: the full path to the po4a-normalize tool. (Not mandatory)
#  PO4A_FOUND: True if asciidoc has been found.
#  PO4A_VERSION_STRING: the version of asciidoc found
#
# Next variables are used by soma macroes:
#  PO4A_TRANSLATE_ARGS: Additional argumets supplied to po4a-translate executable
#
# It also provides the following macros:
# po4a_translate( <master_file> <po_file> FORMAT format [ALL] [DESTINATION <dir>] [OUTPUT file_path] )
#   Translate master_file in the given FORMAT using the po_file translated file.
#   If DESTINATION is given, the appropriate install rule will be created.
#   If ALL is specified, the translation will be build for the all target.
#   If OUTPUT is given the output file will be placed on the given path, otherwise the output will be defaulted to <master_file_name>_<po_file_name>.
#========= Copyright =================================================#
#  Copyright (C) 2015 Alexander Golubev (Fat-Zer) <fatzer2@gmail.com>
#
#  This file is dual licensed. You may use and distribute it providing
#  that you comply EITHER with the terms of the 3-clause BSD license,
#  OR the GPLv2+ license. It is not necessary to comply with both
#  licenses, only one.
#=====================================================================#

find_program( PO4A_EXECUTABLE            po4a            )
find_program( PO4A_BUILD_EXECUTABLE      po4a-build      )
find_program( PO4A_GETTEXTIZE_EXECUTABLE po4a-gettextize )
find_program( PO4A_NORMALIZE_EXECUTABLE  po4a-normalize  )
find_program( PO4A_TRANSLATE_EXECUTABLE  po4a-translate  )
find_program( PO4A_UPDATEPO_EXECUTABLE   po4a-updatepo   )

if( PO4A_EXECUTABLE )
    execute_process( COMMAND ${PO4A_EXECUTABLE} --version
        OUTPUT_VARIABLE _po4a_version
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    string(REGEX REPLACE "^po4a [^ ]+ ([0-9\\.]+).*$" "\\1"
        PO4A_VERSION_STRING "${_po4a_version}")
    string(REGEX REPLACE "\\.$" ""
        PO4A_VERSION_STRING "${PO4A_VERSION_STRING}")
    unset( _po4a_version )
endif()

mark_as_advanced(
    PO4A_EXECUTABLE           
    PO4A_BUILD_EXECUTABLE     
    PO4A_GETTEXTIZE_EXECUTABLE
    PO4A_NORMALIZE_EXECUTABLE 
    PO4A_TRANSLATE_EXECUTABLE 
    PO4A_UPDATEPO_EXECUTABLE  
)

find_package( PackageHandleStandardArgs )

find_package_handle_standard_args( po4a
    REQUIRED_VARS 
        PO4A_EXECUTABLE 
        PO4A_TRANSLATE_EXECUTABLE
        PO4A_UPDATEPO_EXECUTABLE
    VERSION_VAR PO4A_VERSION_STRING
)


function(_po4a_unique_target_name _name _unique_name)
    set( propertyName "_po4a_unique_counter_${_name}" )
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


function (po4a_translate _master _po)
    set( options ALL )
    set( oneValueArgs DESTINATION FORMAT OUTPUT )
    set( multiValueArgs )
    cmake_parse_arguments( _parsed "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    get_filename_component( _master_name "${_master}" NAME)
    string( REGEX REPLACE "^(.+)\\.([^.]+)$" "\\1" _master_basename "${_master_name}")
    string( REGEX REPLACE "^(.+)\\.([^.]+)$" "\\2" _master_ext "${_master_name}")
    get_filename_component( _po_name "${_po}" NAME)
    string( REGEX REPLACE "^(.+)\\.([^.]+)$" "\\1" _po_basename "${_po_name}")

    if( _parsed_OUTPUT )
        if( IS_ABSOLUTE "${_parsed_OUTPUT}" )
            set( _output ${_parsed_OUTPUT} )
        else( )
            set( _output ${CMAKE_CURRENT_BINARY_DIR}/${_parsed_OUTPUT} )
        endif( )
    else( )
        set( _output ${CMAKE_CURRENT_BINARY_DIR}/${_master_name} )
    endif( )

    add_custom_command( OUTPUT "${_output}"
        COMMAND "${PO4A_TRANSLATE_EXECUTABLE}" -f "${_parsed_FORMAT}" -m "${_master}" -p "${_po}" 
            -l "${_output}" ${PO4A_TRANSLATE_ARGS}
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        DEPENDS "${_master}" "${_po}"
        )

    if( _parsed_DESTINATION )
        install( FILES ${_output} DESTINATION ${_parsed_DESTINATION} )
    endif( _parsed_DESTINATION )
    
    _po4a_unique_target_name( "po4a_translate_${_master_basename}_${_po_basename}" _unique_target )
    
    if( _parsed_ALL)
       add_custom_target("${_unique_target}" ALL DEPENDS "${_output}")
    else()
       add_custom_target("${_unique_target}" DEPENDS "${_output}")
    endif()

endfunction ( )
