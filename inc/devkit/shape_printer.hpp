#ifndef SHAPE_PRINTER_HPP
#define SHAPE_PRINTER_HPP

#include <string>

#include "shape.hpp"

namespace devkit {

// Formatea la información de una figura como texto, usando fmt internamente.
[[nodiscard]] std::string DescribeShape(const Shape& shape);

}  // namespace devkit

#endif