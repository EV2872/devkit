add_executable(devkit_app main.cpp)

target_link_libraries(devkit_app
    PRIVATE
        devkit::shapes
        fmt::fmt
)

devkit_configure_target(devkit_app)

set_target_properties(devkit_app PROPERTIES
    OUTPUT_NAME "devkit"
)