#  Copyright (C) 2014 Alexander Golubev (Fat-Zer) <fatzer2@gmail.com>#

build_asciidoc( eeschema.adoc 
    ALL
    DESTINATION ${KICAD_DOC_PATH}
    FORMAT ${KICAD_DOC_FORMAT}
    EXTRA images
)
