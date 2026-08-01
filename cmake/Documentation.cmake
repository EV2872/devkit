# ==============================================================================
# Documentation.cmake
# Genera documentación con Doxygen a partir de inc/ (API pública) y,
# opcionalmente, src/ (implementación) si DEVKIT_DOC_INTERNAL está ON.
# ==============================================================================

option(DEVKIT_BUILD_DOCS "Generar documentación con Doxygen" OFF)
option(DEVKIT_DOC_INTERNAL "Incluir src/ además de inc/ en la documentación" OFF)

function(devkit_register_docs_target)
    if(NOT DEVKIT_BUILD_DOCS)
        return()
    endif()

    find_package(Doxygen REQUIRED dot)

    set(DEVKIT_DOXYGEN_INPUT "${PROJECT_SOURCE_DIR}/inc")
    if(DEVKIT_DOC_INTERNAL)
        set(DEVKIT_DOXYGEN_INPUT "${DEVKIT_DOXYGEN_INPUT} ${PROJECT_SOURCE_DIR}/src")
    endif()

    set(DOXYGEN_IN  "${PROJECT_SOURCE_DIR}/docs/Doxyfile.in")
    set(DOXYGEN_OUT "${PROJECT_BINARY_DIR}/Doxyfile")

    configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)

    add_custom_target(docs
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_SOURCE_DIR}/docs"
        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMENT "Generando documentación con Doxygen en docs/html"
        VERBATIM
    )
endfunction()

devkit_register_docs_target()