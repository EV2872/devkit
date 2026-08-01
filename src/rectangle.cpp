#include "devkit/rectangle.hpp"
#include <string>

namespace devkit {

Rectangle::Rectangle(double width, double height)
    : width_(width), height_(height) {}

double Rectangle::Area() const {
    return width_ * height_;
}

std::string Rectangle::Name() const {
    return "Rectangle";
}

}  // namespace devkit