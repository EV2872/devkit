# ==============================================================================
# Cppcheck.cmake
# Registra el target `cppcheck`, que analiza inc/ y src/ usando
# compile_commands.json (resuelve includes automáticamente, sin duplicar
# flags a mano). Nunca analiza test/ ni dependencias de Conan.
# ==============================================================================

option(ENABLE_CPPCHECK "Habilitar análisis con cppcheck" OFF)

function(devkit_register_cppcheck_target)
    if(NOT ENABLE_CPPCHECK)
        return()
    endif()

    find_program(CPPCHECK cppcheck REQUIRED)

    add_custom_target(cppcheck
        COMMAND ${CPPCHECK}
                --project=${CMAKE_BINARY_DIR}/compile_commands.json
                --enable=warning,performance,portability,style
                --inline-suppr
                --suppress=missingInclude
                --suppress=missingIncludeSystem
                --suppress=unmatchedSuppression
                --suppress=unusedFunction
                --std=c++20
                --template=gcc
                -i${CMAKE_BINARY_DIR}
                --file-filter=${CMAKE_SOURCE_DIR}/src/*
                --file-filter=${CMAKE_SOURCE_DIR}/inc/*
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Ejecutando cppcheck sobre inc/ y src/"
        VERBATIM
    )
endfunction()