project( kicad-doc )

cmake_minimum_required( VERSION 2.8.4 FATAL_ERROR )

set( KICAD_DOC_PATH share/doc/kicad
    CACHE PATH "Location of KiCad documentation files." )

set( KICAD_DOC_FORMAT html
    CACHE STRING "An output kicad documentation format (pdf/html/docbook)" )

mark_as_advanced( KICAD_DOC_PATH )

set( CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules" )

find_package ( Gettext REQUIRED )
find_package ( Asciidoc REQUIRED )
# find_package ( Po4a REQUIRED )

set( ASCIIDOC_ARGS -a 'newline=\\n' --section-numbers
    CACHE INTERNAL "Some additional argument to be passed to asciidoc")
set( ASCIIDOC_A2X_pdf_ARGS --dblatex-opts "-P latex.output.revhistory=0 -P doc.publisher.show=0"
    CACHE INTERNAL "Some additional argument to be passed to asciidoc")

add_subdirectory( src )
