project( kicad-doc )

cmake_minimum_required( VERSION 2.8.4 FATAL_ERROR )

set( KICAD_DOC_PATH share/doc/kicad
    CACHE PATH "Location of KiCad documentation files." )

set( KICAD_DOC_FORMAT html
    CACHE STRING "An output kicad documentation format (pdf/html/docbook)" )

set( KICAD_DOC_TRANSLATIONS fr it po ru
    CACHE STRING "A list of documentation translations to build" )

mark_as_advanced( KICAD_DOC_PATH )

set( CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules" )

find_package ( Asciidoc REQUIRED )
find_package ( Po4a REQUIRED )

include ( KicadDocMacro )

set( ASCIIDOC_ARGS -a 'newline=\\n' --section-numbers
    CACHE INTERNAL "Some additional argument to be passed to asciidoc")
set( ASCIIDOC_A2X_pdf_ARGS --dblatex-opts "-P latex.output.revhistory=0 -P doc.publisher.show=0"
    CACHE INTERNAL "Some additional argument to be passed to a2x for pdf format")
set( PO4A_TRANSLATE_ARGS -k 0 -M utf-8
    CACHE INTERNAL "Some additional argument to be passed to po4a-translate")
set( PO4A_UPDATE_ARGS -M utf-8
    CACHE INTERNAL "Some additional argument to be passed to po4a-update")

check_asciidoc_support_format( "${KICAD_DOC_FORMAT}"
    ASCIIDOC_SUPPORTS_${KICAD_DOC_FORMAT} )

if( NOT "${ASCIIDOC_SUPPORTS_${KICAD_DOC_FORMAT}}" )
    message( FATAL_ERROR
        "The asciidoc toolchain unable to produce output for specified format "
           "(${KICAD_DOC_FORMAT})\n"
        "Please check your installation.\n"
        "Some additional information may be found in the CMakeOutput.log"
    )
endif( )

add_subdirectory( src )
