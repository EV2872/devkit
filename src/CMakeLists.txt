add_library(devkit_shapes STATIC
    circle.cpp
    rectangle.cpp
    shape_printer.cpp
)

add_library(devkit::shapes ALIAS devkit_shapes)

target_include_directories(devkit_shapes
    PUBLIC
        $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/inc>
        $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/generated/inc>
        $<INSTALL_INTERFACE:inc>
)

target_link_libraries(devkit_shapes
    PRIVATE
        fmt::fmt
)

# Aplica warnings, sanitizers, optimizaciones y análisis estático
# SOLO a este target (nuestro código), nunca a fmt ni a gtest.
devkit_configure_target(devkit_shapes)