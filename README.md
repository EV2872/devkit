# Profesional C++ Template (STILL IN PROGRESS)

## WAIT UNTIL VERSION 1.0.0 (ALREADY PUBLIC FOR THE GITHUB ACTIONS)

Configure a C++ project is basically a TORTURE for new users, specially the fact that nowadays every profesional project regardless of the lenguaje uses a bunch of tools delevoped by different people, making it harder to synchronize, find what you need in their documentation... This template might be a overkill for people learning C++ or that they know it but at the same time not really familiarized with the ecosystem that surounds it, firstly I recommend getting familiarized with some of the tools before combining all of them, specially the compiler's options, CMake, Conan and Docker. At the same time I want to state that this template doesnt need to be the perfect template but a set of good practices to make your code reproducible everywhere, let other projects/people to use your library. Feel free to do whatever the MIT lincense allows you to do.

## Software development best practices taken in consideration

Agnostic to programming lenguaje best practices enforced in software development:
- Generate a documentation website (we will use Doxygen and Graphviz)
- Coverage website based on the tests.
- Add a suite of test cases to verify that our does the expected
- Apply fuzzing techniques to find bugs
- Have a Test / Release / Debug configuration
- Use Docker to make the project reproducible and easy to setup almost out of the box (still needs to be polished due the use of Fedora as base Image)
- In this case since the project is about C++ we will compile the project with GCC and Clang as a double check.
- Use of statick analyzer, Sanitizers and debuggers to hopefully reach a bug-free state in our library.
- Speed up compiling process.
- Use of Git for versioning.
- Force a format style across the developers, here we use Google style guide
- Delegate installing third party libraries to a package manager.
- Delegate building process to a building system.
- Separate interface (.hpp) from implementation (.cpp)
- Use contionous integration (CI) to trigger automatized tests/process once we have merged our changes into the main repository, in this case GitHub. <<<IMPORTANT>>> in GitHub it is only free if your repository is public, otherwise you got limited time and you might have to pay.
- Some people might care about the performance of their libraries, so we will have a benchmark for our C++ code.

## C++ project configuration problems

The common problems/configuration in a C++ project that we want to take in consideration:
- Setup CMake to automate our cbuilding/compiling process.
- Setup Conan to download third party libraries (we will use it only for those libraries that our code, tests, benchmark need, the rest are installed via the package manager of the base image OS repositories)
- Setup the standar that we want to use.
- Setup compiler flags.
- Setup static analyzers like clang-tiddy or sanitizers like valgrind to check memory leaks.
- Setup an intelissense that dont panic when included third party libraries or the STL.
- Setup a fuzzer (libFuzzer from Clang)
- Setup Ninja to speed up building process
- Setup Ccache to avoid recompiling

## Dependecies

All you need is Docker and Docker-Compose, usually they even come together through the installation process. The exact version used:
- Docker version 29.6.2, build 1.fc44
- Docker Compose version 5.3.1