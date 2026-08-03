// Ruta: devkit/src/shape_printer.cpp

#include "devkit/shape_printer.hpp"
#include <string>

#include <fmt/core.h>

#include "devkit/shape.hpp"

namespace devkit {

std::string DescribeShape(const Shape& shape) {
    return fmt::format("{}: área = {:.4f}", shape.Name(), shape.Area());
}

}  // namespace devkit