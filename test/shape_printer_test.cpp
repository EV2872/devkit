#include "../inc/devkit/shape_printer.hpp"
#include <string>

#include <gtest/gtest.h>

#include "devkit/circle.hpp"
#include "devkit/rectangle.hpp"

namespace devkit::test {
namespace {

TEST(ShapePrinterTest, DescribesCircleWithNameAndArea) {
    const Circle kCircle(1.0);

    const std::string kDescription = DescribeShape(kCircle);

    EXPECT_NE(kDescription.find("Circle"), std::string::npos);
    EXPECT_NE(kDescription.find("área"), std::string::npos);
}

TEST(ShapePrinterTest, DescribesRectangleWithNameAndArea) {
    const Rectangle kRectangle(2.0, 3.0);

    const std::string kDescription = DescribeShape(kRectangle);

    EXPECT_NE(kDescription.find("Rectangle"), std::string::npos);
}

}  // namespace
}  // namespace devkit::test