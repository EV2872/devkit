#include <cstdint>
#include <cstddef>
#include <cstring>

#include "devkit/circle.hpp"
#include "devkit/shape_printer.hpp"

// libFuzzer provee su propio main(); esta función es el punto de entrada.
extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
    if (size < sizeof(double)) {
        return 0;
    }

    double radius = 0.0;
    std::memcpy(&radius, data, sizeof(double));

    devkit::Circle circle(radius);
    static_cast<void>(devkit::DescribeShape(circle));  // objetivo: que no crashee/UB con cualquier radius

    return 0;
}