#ifndef SHAPE_PRINTER_HPP
#define SHAPE_PRINTER_HPP

#include "devkit/export.h"

#include <string>

#include "shape.hpp"

namespace devkit {

// Formatea la información de una figura como texto, usando fmt internamente.
[[nodiscard]] DEVKIT_API std::string DescribeShape(const Shape& shape);

}  // namespace devkit

#endif