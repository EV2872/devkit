# Changelog ejemplo

Todos los cambios notables de este proyecto se documentan aquí.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto usa [Versionado Semántico](https://semver.org/lang/es/).

## [0.2.0] - 2026-08-01

## [0.1.0] - 2026-08-01

### Added
- Librería `devkit_shapes` (`Circle`, `Rectangle`, `ShapePrinter`) sobre `fmt`.
- Ejecutable `devkit_app` de ejemplo, separado de la librería.
- Tests con GoogleTest/GoogleMock, ejecutados con sanitizers (ASan+UBSan) en Debug.
- Análisis estático: clang-tidy (por target) y cppcheck (target `cppcheck` independiente).
- Coverage con gcovr (target `coverage`).
- Validación de memoria con Valgrind (target `memcheck`).
- Documentación generada con Doxygen (target `docs`).
- Empaquetado y distribución: `cmake --install`, `FetchContent`, y paquete Conan
  validado con `test_package/`.
- Entorno de desarrollo reproducible vía Docker + Docker Compose.
- CI en GitHub Actions (formato, build+test en Debug/Release, coverage, valgrind, docs).