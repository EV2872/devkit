#ifndef SHAPE_HPP
#define SHAPE_HPP

#include <string>

#include "devkit/export.h"

namespace devkit {

// Interfaz base de una figura geométrica. Ejemplo mínimo para la plantilla.
class DEVKIT_API Shape {
  public:
    Shape() = default;
    virtual ~Shape() = default;

    Shape(const Shape&) = default;
    Shape& operator=(const Shape&) = default;
    Shape(Shape&&) noexcept = default;
    Shape& operator=(Shape&&) noexcept = default;

    [[nodiscard]] virtual double Area() const = 0;
    [[nodiscard]] virtual std::string Name() const = 0;
};

}  // namespace devkit

#endif