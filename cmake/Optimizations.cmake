# ==============================================================================
# Optimizations.cmake
# Optimizaciones explícitas para Release. Solo se incluyen optimizaciones que
# NO alteran la semántica del programa (nada de -ffast-math, -funsafe-math-*, etc).
# ==============================================================================

function(devkit_set_release_optimizations target_name)
    if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")
        return()
    endif()

    set(SAFE_OPTIMIZATION_FLAGS
        -O3                     # Máximo nivel de optimización estándar
        -DNDEBUG                # Desactiva asserts en Release
        -fomit-frame-pointer    # Libera un registro extra; seguro salvo debug con frame walking
        -funroll-loops          # Desenrollado de bucles; no altera semántica
    )

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(${target_name} PRIVATE
            ${SAFE_OPTIMIZATION_FLAGS}
            -g1                      # Info de debug mínima (line tables), sin coste de rendimiento real
            -ffunction-sections
            -fdata-sections
        )
        target_link_options(${target_name} PRIVATE
            -Wl,--gc-sections
        )

        devkit_split_debug_symbols(${target_name})
    endif()

    message(STATUS "[${target_name}] Optimizaciones Release aplicadas: ${SAFE_OPTIMIZATION_FLAGS}")
endfunction()

# ------------------------------------------------------------------------------
# Separa los símbolos de debug del binario final a un fichero .debug aparte,
# vinculado por debug-link. El binario de producción queda ligero (sin
# símbolos embebidos) pero se puede reasociar con gdb si hace falta investigar
# un crash real, sin sacrificar -O3 ni el tamaño del binario desplegado.
# ------------------------------------------------------------------------------
function(devkit_split_debug_symbols target_name)
    # La separación de símbolos solo tiene sentido en binarios finales
    # (ejecutables/bibliotecas compartidas). Aplicarlo a una biblioteca
    # estática (.a) es destructivo: --strip-unneeded elimina símbolos que
    # parecen "no usados" dentro de esa unidad pero que sí hacen falta al
    # enlazar contra ella después, y con LTO corrompe el bytecode IR interno.
    get_target_property(target_type ${target_name} TYPE)
    if(target_type STREQUAL "STATIC_LIBRARY")
        return()
    endif()

    find_program(OBJCOPY_PROGRAM objcopy)
    find_program(STRIP_PROGRAM strip)

    if(NOT OBJCOPY_PROGRAM OR NOT STRIP_PROGRAM)
        message(STATUS "objcopy/strip no encontrados: se omite separación de símbolos")
        return()
    endif()

    add_custom_command(TARGET ${target_name} POST_BUILD
        COMMAND ${OBJCOPY_PROGRAM} --only-keep-debug
                $<TARGET_FILE:${target_name}>
                $<TARGET_FILE:${target_name}>.debug
        COMMAND ${STRIP_PROGRAM} --strip-debug --strip-unneeded
                $<TARGET_FILE:${target_name}>
        COMMAND ${OBJCOPY_PROGRAM} --add-gnu-debuglink=$<TARGET_FILE:${target_name}>.debug
                $<TARGET_FILE:${target_name}>
        COMMENT "Separando símbolos de debug de ${target_name} en un fichero .debug aparte"
        VERBATIM
    )
endfunction()