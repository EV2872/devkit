# ==============================================================================
# Coverage.cmake
# Instrumentación de cobertura (gcov flags) + target `coverage` que ejecuta
# gcovr y genera el reporte HTML en coverage/.
# Solo se aplica por target propio, nunca a dependencias de Conan.
# ==============================================================================

option(DEVKIT_ENABLE_COVERAGE "Instrumentar el código para medir cobertura" OFF)

function(devkit_enable_coverage target_name)
    if(NOT DEVKIT_ENABLE_COVERAGE)
        return()
    endif()

    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
        message(WARNING "Coverage habilitado fuera de Debug: los resultados pueden ser engañosos (optimizaciones alteran el mapeo de líneas)")
    endif()

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(${target_name} PRIVATE
            --coverage
            -fno-inline
            -fno-inline-small-functions
            -fno-default-inline
        )
        target_link_options(${target_name} PRIVATE --coverage)
    else()
        message(WARNING "Coverage no soportado para el compilador actual")
    endif()
endfunction()

function(devkit_register_coverage_target)
    if(NOT DEVKIT_ENABLE_COVERAGE)
        return()
    endif()

    find_program(GCOVR_PROGRAM gcovr REQUIRED)

    add_custom_target(coverage
        COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_SOURCE_DIR}/coverage"
        COMMAND ${GCOVR_PROGRAM}
                --root "${PROJECT_SOURCE_DIR}"
                --filter "${PROJECT_SOURCE_DIR}/src/.*"
                --filter "${PROJECT_SOURCE_DIR}/inc/.*"
                --exclude "${PROJECT_SOURCE_DIR}/test/.*"
                --object-directory "${PROJECT_BINARY_DIR}"
                --html --html-details
                --output "${PROJECT_SOURCE_DIR}/coverage/index.html"
                --print-summary
                --fail-under-line 0
        WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
        DEPENDS devkit_tests
        COMMENT "Generando reporte de cobertura en coverage/index.html"
        VERBATIM
    )
endfunction()