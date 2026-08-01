# ==============================================================================
# StaticAnalyzers.cmake
# clang-tidy e IWYU aplicados por target (vía CXX_CLANG_TIDY/CXX_INCLUDE_WHAT_YOU_USE).
# cppcheck se registra como target independiente `cppcheck` (ver Cppcheck.cmake),
# ya que --project es incompatible con la invocación por-fichero de CXX_CPPCHECK.
# Todos analizan EXCLUSIVAMENTE nuestro propio código, nunca dependencias de Conan.
# ==============================================================================

option(ENABLE_CLANG_TIDY "Habilitar análisis con clang-tidy" OFF)
option(ENABLE_IWYU "Habilitar análisis con include-what-you-use" OFF)

function(devkit_enable_static_analysis target_name)
    if(ENABLE_CLANG_TIDY)
        find_program(CLANGTIDY clang-tidy)
        if(CLANGTIDY)
            set_target_properties(${target_name} PROPERTIES
                CXX_CLANG_TIDY "${CLANGTIDY};--extra-arg=-Wno-unknown-warning-option"
            )
        else()
            message(WARNING "clang-tidy solicitado pero no encontrado")
        endif()
    endif()

    if(ENABLE_IWYU)
        find_program(IWYU include-what-you-use)
        if(IWYU)
            set_target_properties(${target_name} PROPERTIES
                CXX_INCLUDE_WHAT_YOU_USE "${IWYU};-Xiwyu;--mapping_file=${CMAKE_SOURCE_DIR}/cmake/iwyu.imp"
            )
        else()
            message(WARNING "include-what-you-use solicitado pero no encontrado")
        endif()
    endif()
endfunction()   