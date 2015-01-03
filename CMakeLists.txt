project( kicad-doc )

cmake_minimum_required( VERSION 2.8.4 FATAL_ERROR )

set( KICAD_DOC_PATH share/doc/kicad
    CACHE PATH "Location of KiCad documentation files." )

set( KICAD_DOC_FORMAT html
    CACHE STRING "An output kicad documentation format (pdf/html/docbook)" )

set( KICAD_DOC_TRANSLATIONS ru fr it
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

add_subdirectory( src )
