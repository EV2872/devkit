add_library(devkit_shapes
    circle.cpp
    rectangle.cpp
    shape_printer.cpp
)

add_library(devkit::shapes ALIAS devkit_shapes)


# ==============================================================================
# Genera inc/devkit/export.h automáticamente, con el macro DEVKIT_API que
# expande a visibility("default")/dllexport/dllimport según cómo se compile
# y consuma la librería (estática, compartida propia, o compartida externa).
# Necesario porque CMAKE_CXX_VISIBILITY_PRESET=hidden oculta todo por defecto.
# ==============================================================================
include(GenerateExportHeader)
generate_export_header(devkit_shapes
    BASE_NAME devkit
    EXPORT_MACRO_NAME DEVKIT_API
    EXPORT_FILE_NAME ${CMAKE_CURRENT_BINARY_DIR}/generated/inc/devkit/export.h
)


target_include_directories(devkit_shapes
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/inc>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/generated/inc>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated/inc>
        $<INSTALL_INTERFACE:inc>
)

target_link_libraries(devkit_shapes
    PRIVATE
        fmt::fmt
)

# Aplica warnings, sanitizers, optimizaciones y análisis estático
# SOLO a este target (nuestro código), nunca a fmt ni a gtest.
devkit_configure_target(devkit_shapes)