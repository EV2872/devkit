#include <cstdlib>

#include "devkit/circle.hpp"

int main() {
    const devkit::Circle kCircle(2.0);
    return kCircle.Area() > 0.0 ? EXIT_SUCCESS : EXIT_FAILURE;
}