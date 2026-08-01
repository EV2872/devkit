# ==============================================================================
# DebugInfo.cmake
# Garantiza símbolos de debug completos y sin optimización en Debug, para que
# gdb/lldb y valgrind den trazas útiles (línea exacta, variables inspeccionables).
# ==============================================================================

function(devkit_set_debug_info target_name)
    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
        return()
    endif()

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(${target_name} PRIVATE
            -g3                  # Máximo nivel de info de debug (incluye macros)
            -Og                  # Optimización pensada para debugging (mejor que -O0 puro)
            -fno-omit-frame-pointer   # Necesario para backtraces fiables en gdb/valgrind
        )
    endif()
endfunction()