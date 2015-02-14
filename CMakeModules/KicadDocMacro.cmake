#  Copyright (C) 2015 Alexander Golubev (Fat-Zer) <fatzer2@gmail.com>#

##
# Usage: kicad_doc_build ( doc.adoc [LANG lang] [EXTRA extra] )
#
function( kicad_doc_build _doc )
    set( options )
    set( oneValueArgs LANG )
    set( multiValueArgs EXTRA )
    cmake_parse_arguments( _parsed "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if( _parsed_EXTRA )
        list( APPEND _build_asciidoc_args EXTRA ${_parsed_EXTRA})
    endif( )

    if( _parsed_EXTRA )
        list( APPEND _build_asciidoc_args EXTRA ${_parsed_EXTRA})
    endif( )
    if( _parsed_LANG )
        list( APPEND _build_asciidoc_args LANG "${_parsed_LANG}")
    endif( )

    build_asciidoc( "${_doc}"
        ALL
        DESTINATION "${KICAD_DOC_PATH}"
        FORMAT "${KICAD_DOC_FORMAT}"
        ${_build_asciidoc_args}
    )
endfunction( )

##
# Usage: kicad_doc_translate ( doc.adoc [EXTRA extra] )
#
function( kicad_doc_translate _doc )
    set( options )
    set( oneValueArgs )
    set( multiValueArgs EXTRA )
    cmake_parse_arguments( _parsed "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if( _parsed_EXTRA )
        list( APPEND _build_asciidoc_args EXTRA ${_parsed_EXTRA})
    endif( )

    get_filename_component( _doc_name "${_doc}" NAME)
    string( REGEX REPLACE "^(.+)\\.([^.]+)$" "\\1" _doc_basename "${_doc_name}")
    string( REGEX REPLACE "^(.+)\\.([^.]+)$" "\\2" _doc_ext "${_doc_name}")

    foreach( _lang ${KICAD_DOC_TRANSLATIONS} )
        set( _current_po "${CMAKE_CURRENT_SOURCE_DIR}/po/${_lang}.po" )

        if( EXISTS "${_current_po}" )
            set( _translated_doc "${CMAKE_CURRENT_BINARY_DIR}/${_doc_basename}-${_lang}.${_doc_ext}" )
            set( _addendum "${CMAKE_CURRENT_SOURCE_DIR}/po/addendum.${_lang}" )
            if( EXISTS "${_addendum}" )
                set( _po4a_extra_args ADDENDUM "${_addendum}")
            endif( )
            po4a_translate( "${_doc}" "${_current_po}"
                FORMAT asciidoc
                OUTPUT "${_translated_doc}"
                ${_po4a_extra_args}
            )
            kicad_doc_build( "${_translated_doc}" LANG "${_lang}" ${_build_asciidoc_args} )

            # add an updatepo[-*] targets
            po4a_updatepo( "${_doc}" "${_current_po}"
                TARGET updatepo "updatepo-${_lang}" "updatepo-${_doc_basename}-${_lang}"
                FORMAT asciidoc
            )
        endif( )
    endforeach( )
endfunction( )
