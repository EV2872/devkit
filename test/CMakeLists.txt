find_package(GTest REQUIRED)

add_executable(devkit_tests
    circle_test.cpp
    rectangle_test.cpp
    shape_printer_test.cpp
    shape_mock_test.cpp
)

target_link_libraries(devkit_tests
    PRIVATE
        devkit::shapes
        GTest::gtest
        GTest::gtest_main
        GTest::gmock
)

devkit_configure_target(devkit_tests)

# Descubre automáticamente los tests individuales dentro del ejecutable,
# en vez de tratarlo como un único test monolítico — permite ver en CTest
# cada TEST()/TEST_F() por separado, con su propio resultado pass/fail.
include(GoogleTest)
gtest_discover_tests(devkit_tests
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    PROPERTIES LABELS "unit"
)

set_target_properties(devkit_tests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin/test"
)