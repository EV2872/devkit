cmake_minimum_required(VERSION 3.25)
project(devkit_test_package LANGUAGES CXX)

find_package(devkit REQUIRED)

add_executable(example example.cpp)
target_link_libraries(example PRIVATE devkit::shapes)

set_target_properties(example PROPERTIES
    CXX_STANDARD 20
    CXX_STANDARD_REQUIRED ON
)