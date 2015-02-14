#  Copyright (C) 2015 Alexander Golubev (Fat-Zer) <fatzer2@gmail.com>#

##
# Usage: kicad_doc_build ( doc.adoc [LANG lang] [EXTRA_SOURCE extra_source ... ] [EXTRA_DATA extra] )
#
function( kicad_doc_build _doc )
    set( options )
    set( oneValueArgs LANG )
    set( multiValueArgs EXTRA_DATA )
    cmake_parse_arguments( _parsed "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if( _parsed_EXTRA_SOURCE )
        list( APPEND _build_asciidoc_args EXTRA_SOURCE ${_parsed_EXTRA_SOURCE} )
    endif( )
    if( _parsed_EXTRA_DATA )
        list( APPEND _build_asciidoc_args EXTRA_DATA ${_parsed_EXTRA_DATA} )
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
# Usage: kicad_doc_translate ( doc.adoc [EXTRA_SOURCE extra_source ... ] [EXTRA_DATA extra] )
#
function( kicad_doc_translate _doc )
    set( options )
    set( oneValueArgs )
    set( multiValueArgs EXTRA_DATA )
    cmake_parse_arguments( _parsed "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    get_filename_component( _doc_name "${_doc}" NAME)
    string( REGEX REPLACE "^(.+)\\.([^.]+)$" "\\1" _doc_basename "${_doc_name}")
    string( REGEX REPLACE "^(.+)\\.([^.]+)$" "\\2" _doc_ext "${_doc_name}")

    foreach( _lang ${KICAD_DOC_TRANSLATIONS} )
        set( _current_po "${CMAKE_CURRENT_SOURCE_DIR}/po/${_lang}.po" )

        if( EXISTS "${_current_po}" )
            # reset some variables
            set( _translated_extra_doc )
            set( _build_asciidoc_args )

            set( _translate_dir "${CMAKE_CURRENT_BINARY_DIR}/${_lang}" )

            # translate additional source files
            foreach( _source_doc "${_doc}" ${_parsed_EXTRA_SOURCE} )
                get_filename_component( _source_doc_name "${_source_doc}" NAME)
                set( _translated_doc "${_translate_dir}/${_source_doc_name}" )
                po4a_translate( "${_source_doc}" "${_current_po}"
                    FORMAT asciidoc
                    OUTPUT "${_translated_doc}"
                    ${_po4a_extra_args}
                )
                list( APPEND _translated_extra_doc "${_translated_doc}" )
            endforeach( )


            # translate the master file
            set( _translated_doc "${_translate_dir}/${_doc_basename}-${_lang}.adoc" )
            set( _addendum "${CMAKE_CURRENT_SOURCE_DIR}/po/addendum.${_lang}" )
            if( EXISTS "${_addendum}" )
                set( _po4a_extra_args ADDENDUM "${_addendum}")
            endif( )

            po4a_translate( "${_doc}" "${_current_po}"
                FORMAT asciidoc
                OUTPUT "${_translated_doc}"
                ${_po4a_extra_args}
            )

            if( _translated_extra_doc )
                list( APPEND _build_asciidoc_args EXTRA_SOURCE ${_translated_extra_doc})
            endif( )

            if( _parsed_EXTRA_DATA )
                list( APPEND _build_asciidoc_args EXTRA_DATA ${_parsed_EXTRA_DATA})
            endif( )

            kicad_doc_build( "${_translated_doc}" LANG "${_lang}" ${_build_asciidoc_args} )

            # add updatepo[-*] targets
            po4a_updatepo( "${_doc}" "${_current_po}"
                EXTRA_MASTER ${_parsed_EXTRA_SOURCE}
                TARGET updatepo "updatepo-${_lang}" "updatepo-${_doc_basename}-${_lang}"
                FORMAT asciidoc
            )
        endif( )
    endforeach( )
endfunction( )

##
# Usage: kicad_doc_build ( doc.adoc ... )
#
# The same arguments will be passed to kicad_doc_build as well as to kicad_doc_translate
#
function( kicad_do_doc _doc )
    kicad_doc_build( ${_doc} ${ARGN} )
    kicad_doc_translate( ${_doc} ${ARGN} )
endfunction( )
