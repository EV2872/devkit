#include <fmt/core.h>

#include "devkit/circle.hpp"
#include "devkit/rectangle.hpp"
#include "devkit/shape_printer.hpp"
#include "devkit/version.h"

int main() {
    fmt::print("devkit v{} (commit {}, build {})\n",
               devkit::version::kVersionString,
               devkit::version::kGitCommitHash,
               devkit::version::kBuildType);

    const devkit::Circle kCircle(2.0);
    const devkit::Rectangle kRectangle(3.0, 4.0);

    fmt::print("{}\n", devkit::DescribeShape(kCircle));
    fmt::print("{}\n", devkit::DescribeShape(kRectangle));

    return 0;
}