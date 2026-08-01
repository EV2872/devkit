# ==============================================================================
# Version.cmake
# Genera inc/devkit/version.h a partir de version/version.h.in, incluyendo
# el hash de git del commit actual para trazabilidad de builds.
# ==============================================================================

function(devkit_generate_version_header)
    find_package(Git QUIET)

    set(DEVKIT_GIT_COMMIT_HASH "unknown")
    if(Git_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
            WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
            OUTPUT_VARIABLE DEVKIT_GIT_COMMIT_HASH
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(NOT DEVKIT_GIT_COMMIT_HASH)
            set(DEVKIT_GIT_COMMIT_HASH "unknown")
        endif()
    endif()

    configure_file(
        "${PROJECT_SOURCE_DIR}/version/version.h.in"
        "${PROJECT_BINARY_DIR}/generated/inc/devkit/version.h"
        @ONLY
    )
endfunction()

devkit_generate_version_header()