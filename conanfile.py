from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout


class DevkitConan(ConanFile):
    name = "devkit"
    version = "0.2.0"
    license = "MIT"
    url = "https://github.com/tu-usuario/devkit"
    description = "Librería de ejemplo de figuras geométricas (Circle, Rectangle) sobre fmt."
    topics = ("geometry", "shapes", "example")

    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}

    exports_sources = (
        "CMakeLists.txt",
        "cmake/*",
        "inc/*",
        "src/*",
        "version/*",
    )

    def config_options(self):
        if self.settings.os == "Windows":
            self.options.rm_safe("fPIC")

    def configure(self):
        if self.options.shared:
            self.options.rm_safe("fPIC")

    def layout(self):
        # scripts/configure.sh pasa -c user.devkit:local_dev=True porque ya
        # gestiona su propio build folder vía --output-folder. cmake_layout()
        # solo debe aplicarse cuando Conan empaqueta (`conan create`), donde
        # gestiona el source/build folder en su propia caché interna.
        if self.conf.get("user.devkit:local_dev", check_type=bool, default=False):
            return
        cmake_layout(self)

    def requirements(self):
        self.requires("fmt/11.0.2")

    def build_requirements(self):
        self.test_requires("gtest/1.15.0")

    def generate(self):
        tc = CMakeToolchain(self)
        tc.generate()
        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure(
            build_script_folder=self.source_folder,
            variables={
                "DEVKIT_BUILD_TESTS": "OFF",
                "DEVKIT_BUILD_APP": "OFF",
            },
        )
        cmake.build(target="devkit_shapes")

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = ["devkit_shapes"]
        self.cpp_info.set_property("cmake_target_name", "devkit::shapes")
        self.cpp_info.set_property("cmake_file_name", "devkit")