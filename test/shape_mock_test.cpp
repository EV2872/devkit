#include <string>

#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "devkit/shape.hpp"
#include "devkit/shape_printer.hpp"

namespace devkit::test {
namespace {

class MockShape final : public Shape {
  public:
    MOCK_METHOD(double, Area, (), (const, override));
    MOCK_METHOD(std::string, Name, (), (const, override));
};

using ::testing::Return;

TEST(ShapeMockTest, DescribeShapeCallsAreaAndNameExactlyOnce) {
    MockShape mock_shape;

    EXPECT_CALL(mock_shape, Name()).Times(1).WillOnce(Return("MockShape"));
    EXPECT_CALL(mock_shape, Area()).Times(1).WillOnce(Return(42.0));

    const std::string kDescription = DescribeShape(mock_shape);

    EXPECT_EQ(kDescription, "MockShape: área = 42.0000");
}

}  // namespace
}  // namespace devkit::test