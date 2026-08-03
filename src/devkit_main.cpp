// src/devkit_main.cpp
#include <iostream>
#include "devkit/version.h"

int main(int argc, char** argv) {
    (void)argc; (void)argv;
    std::cout << ">>> [DEVKIT] Running from library-provided main()" << '\n';
    std::cout << ">>> [DEVKIT] Framework Version: " << devkit::version::kVersionString << '\n';
    return 0;
}