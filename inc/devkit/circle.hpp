#ifndef CIRCLE_HPP
#define CIRCLE_HPP

#include <string>
#include "shape.hpp"

namespace devkit {

class Circle final : public Shape {
   public:
    explicit Circle(double radius);

    [[nodiscard]] double Area() const override;
    [[nodiscard]] std::string Name() const override;

   private:
    double radius_;
};

}  // namespace devkit

#endif