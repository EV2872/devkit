# ==============================================================================
# Valgrind.cmake
# Registra un target `memcheck` que corre la suite de tests bajo valgrind.
# Incompatible con sanitizers (ASan/UBSan) — usar SOLO en builds sin ellos.
# ==============================================================================

option(DEVKIT_ENABLE_VALGRIND "Habilitar el target memcheck con valgrind" OFF)

function(devkit_register_valgrind_target)
    if(NOT DEVKIT_ENABLE_VALGRIND)
        return()
    endif()

    if(ENABLE_SANITIZERS OR CMAKE_BUILD_TYPE STREQUAL "Debug")
        message(WARNING
            "Valgrind y los sanitizers (ASan/UBSan) no deben combinarse: "
            "usa el preset 'valgrind' dedicado, no 'debug'."
        )
    endif()

    find_program(VALGRIND_PROGRAM valgrind REQUIRED)

    add_custom_target(memcheck
        COMMAND ${VALGRIND_PROGRAM}
                --tool=memcheck
                --leak-check=full
                --show-leak-kinds=all
                --track-origins=yes
                --error-exitcode=1
                --suppressions=${PROJECT_SOURCE_DIR}/cmake/valgrind.supp
                $<TARGET_FILE:devkit_tests>
        DEPENDS devkit_tests
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
        COMMENT "Ejecutando devkit_tests bajo valgrind memcheck"
        VERBATIM
    )
endfunction()