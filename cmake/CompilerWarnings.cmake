# ==============================================================================
# CompilerWarnings.cmake
# Warnings estrictos, aplicados SOLO a nuestro propio código (no a dependencias)
# ==============================================================================

function(devkit_set_project_warnings target_name)
    set(CLANG_GCC_WARNINGS
        -Wall
        -Wextra
        -Wpedantic
        -Wshadow
        -Wnon-virtual-dtor
        -Wold-style-cast
        -Wcast-align
        -Wunused
        -Woverloaded-virtual
        -Wconversion
        -Wsign-conversion
        -Wnull-dereference
        -Wdouble-promotion
        -Wformat=2
        -Wimplicit-fallthrough
        -Werror
    )

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        list(APPEND CLANG_GCC_WARNINGS -Wno-c++98-compat)
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        list(APPEND CLANG_GCC_WARNINGS
            -Wduplicated-cond
            -Wduplicated-branches
            -Wlogical-op
            -Wuseless-cast
        )
    endif()

    target_compile_options(${target_name} PRIVATE ${CLANG_GCC_WARNINGS})
endfunction()