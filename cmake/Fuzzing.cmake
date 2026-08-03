# ==============================================================================
# Fuzzing.cmake
# Registra ejecutables de fuzzing con libFuzzer (solo Clang). Cada fuzzer es
# un target independiente, sin main() propio — libFuzzer lo provee.
# ==============================================================================

option(DEVKIT_BUILD_FUZZERS "Compilar los fuzz targets (requiere Clang)" OFF)

function(devkit_add_fuzzer target_name)
    if(NOT DEVKIT_BUILD_FUZZERS)
        return()
    endif()

    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        message(FATAL_ERROR "DEVKIT_BUILD_FUZZERS requiere Clang. Usa: ./scripts/configure.sh debug clang")
    endif()

    add_executable(${target_name} ${ARGN})

    target_link_libraries(${target_name} PRIVATE devkit::shapes)

    target_compile_options(${target_name} PRIVATE -fsanitize=fuzzer,address,undefined -g -O1)
    target_link_options(${target_name} PRIVATE -fsanitize=fuzzer,address,undefined)

    set_target_properties(${target_name} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY               "${PROJECT_SOURCE_DIR}/bin/fuzz"
        RUNTIME_OUTPUT_DIRECTORY_DEBUG          "${PROJECT_SOURCE_DIR}/bin/fuzz"
        RUNTIME_OUTPUT_DIRECTORY_RELEASE        "${PROJECT_SOURCE_DIR}/bin/fuzz"
    )
endfunction()