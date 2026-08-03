#ifndef RECTANGLE_HPP
#define RECTANGLE_HPP

#include <string>

#include "devkit/export.h"

#include "shape.hpp"

namespace devkit {

/// @brief Representa un círculo definido por su radio.
class DEVKIT_API Rectangle final : public Shape {
  public:
    /// @brief Construye un círculo.
    /// @param radius Radio del círculo, en unidades arbitrarias. Debe ser >= 0.
    explicit Rectangle(double width, double height);

    /// @brief Calcula el área del círculo (π · r²).
    /// @return Área del círculo.
    [[nodiscard]] double Area() const override;

    /// @brief Nombre legible de la figura.
    /// @return La cadena "Circle".
    [[nodiscard]] std::string Name() const override;

  private:
    double width_;
    double height_;
};

}  // namespace devkit

#endif