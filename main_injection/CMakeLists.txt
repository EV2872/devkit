add_executable(devkit_injection_test verify.cpp)

target_link_libraries(devkit_injection_test
    PRIVATE
        devkit::shapes_main
)

# Lo enviamos a bin/debug para encontrarlo fácil
set_target_properties(devkit_injection_test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin/debug"
)