#include "devkit/circle.hpp"
#include <numbers>

#include <gtest/gtest.h>

namespace devkit::test {
namespace {

TEST(CircleTest, AreaIsComputedCorrectly) {
    const Circle kCircle(2.0);

    EXPECT_NEAR(kCircle.Area(), std::numbers::pi * 4.0, 1e-9);
}

TEST(CircleTest, NameReturnsCircle) {
    const Circle kCircle(1.0);

    EXPECT_EQ(kCircle.Name(), "Circle");
}

TEST(CircleTest, ZeroRadiusHasZeroArea) {
    const Circle kCircle(0.0);

    EXPECT_DOUBLE_EQ(kCircle.Area(), 0.0);
}

}  // namespace
}  // namespace devkit::test