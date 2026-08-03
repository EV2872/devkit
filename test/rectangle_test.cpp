#include "devkit/rectangle.hpp"

#include <gtest/gtest.h>

namespace devkit::test {
namespace {

TEST(RectangleTest, AreaIsComputedCorrectly) {
    const Rectangle kRectangle(3.0, 4.0);

    EXPECT_DOUBLE_EQ(kRectangle.Area(), 12.0);
}

TEST(RectangleTest, NameReturnsRectangle) {
    const Rectangle kRectangle(1.0, 1.0);

    EXPECT_EQ(kRectangle.Name(), "Rectangle");
}

// Test parametrizado — buena práctica para evitar duplicar TESTs casi idénticos
class RectangleAreaParamTest : public ::testing::TestWithParam<std::tuple<double, double, double>> {
};

TEST_P(RectangleAreaParamTest, ComputesExpectedArea) {
    const auto [width, height, expected_area] = GetParam();
    const Rectangle kRectangle(width, height);

    EXPECT_DOUBLE_EQ(kRectangle.Area(), expected_area);
}

INSTANTIATE_TEST_SUITE_P(VariousDimensions,
                         RectangleAreaParamTest,
                         ::testing::Values(std::make_tuple(1.0, 1.0, 1.0),
                                           std::make_tuple(2.0, 5.0, 10.0),
                                           std::make_tuple(0.0, 5.0, 0.0)));

}  // namespace
}  // namespace devkit::test