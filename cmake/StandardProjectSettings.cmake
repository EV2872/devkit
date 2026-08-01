# ==============================================================================
# StandardProjectSettings.cmake
# Configuración estándar aplicada a todo el proyecto (independiente del target)
# ==============================================================================

# Evita builds "in-source" (contaminar la raíz del repo con artefactos)
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
    message(FATAL_ERROR
        "No se permiten builds in-source. Usa un directorio de build "
        "separado, p. ej.: cmake --preset <preset>"
    )
endif()

# Tipo de build por defecto si no se especifica
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Tipo de build" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
        "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
endif()

# Genera compile_commands.json (necesario para clangd, clang-tidy, IWYU...)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "" FORCE)

# Exporta símbolos ocultos por defecto en Linux/macOS (buena práctica en libs)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

# Interprocedural Optimization (LTO) solo en Release, si el compilador lo soporta
include(CheckIPOSupported)
check_ipo_supported(RESULT ipo_supported OUTPUT ipo_error)
if(ipo_supported AND CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)

    # LTO en bibliotecas estáticas requiere gcc-ar/gcc-ranlib (compatibles con
    # bytecode LTO); ar/ranlib genéricos de binutils generan un índice de
    # símbolos incorrecto y provocan "undefined reference" en el link final
    # aunque el símbolo exista físicamente en el .a.
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        find_program(GCC_AR_PROGRAM NAMES "${CMAKE_CXX_COMPILER_AR}" gcc-ar)
        find_program(GCC_RANLIB_PROGRAM NAMES "${CMAKE_CXX_COMPILER_RANLIB}" gcc-ranlib)
        if(GCC_AR_PROGRAM AND GCC_RANLIB_PROGRAM)
            set(CMAKE_AR "${GCC_AR_PROGRAM}")
            set(CMAKE_RANLIB "${GCC_RANLIB_PROGRAM}")
        else()
            message(WARNING "gcc-ar/gcc-ranlib no encontrados: LTO con bibliotecas estáticas puede fallar al enlazar")
        endif()
    endif()
endif()