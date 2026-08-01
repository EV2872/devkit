# ==============================================================================
# ccache.cmake
# Habilita ccache automáticamente como launcher de compilación si está disponible
# ==============================================================================

find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_PROGRAM} CACHE STRING "")
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM} CACHE STRING "")
else()
    message(STATUS "ccache no encontrado, se compilará sin caché")
endif()