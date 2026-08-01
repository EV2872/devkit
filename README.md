# devkit

Plantilla profesional de proyecto C++ con Docker, CMake + Presets, Conan, sanitizers, análisis estático, coverage, documentación automática y CI.

---

## 1. Requisitos previos

Solo necesitas tener instalado en tu máquina (host):

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2, integrado en `docker` en instalaciones recientes)

No necesitas instalar CMake, Conan, GCC, Clang, ni ninguna otra herramienta de desarrollo en tu máquina — todo vive dentro del contenedor Docker, garantizando que el entorno sea idéntico para cualquier persona que clone el repositorio.

---

## 2. Primeros pasos (desde cero)

### 2.1. Construir la imagen y levantar el contenedor

```bash
docker-compose -f docker/docker-compose.yml build
docker-compose -f docker/docker-compose.yml up -d
docker-compose -f docker/docker-compose.yml exec dev-env bash
```

A partir de aquí, **todos los comandos de este README se ejecutan dentro del contenedor** (verás el prompt `[dev@... project]$`), salvo que se indique explícitamente "desde el host".

### 2.2. Compilar y probar por primera vez

```bash
./scripts/configure.sh debug
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

Si los tests pasan, el entorno está listo.

### 2.3. Ejecutar el binario de la aplicación

```bash
./bin/debug/devkit
```

### 2.4. Salir / volver a entrar más tarde

```bash
exit                                                            # el contenedor sigue corriendo en segundo plano
docker-compose -f docker/docker-compose.yml exec dev-env bash   # vuelve a entrar
docker-compose -f docker/docker-compose.yml down                # detiene y elimina el contenedor (los volúmenes ccache/conan persisten)
```

---

## 3. Estructura del proyecto

```
devkit/
├── docker/          # Dockerfile, docker-compose.yml, requirements.txt, .env
├── cmake/           # Módulos CMake (warnings, sanitizers, optimizaciones, análisis estático...)
├── conan/           # Perfiles y settings_user.yml de Conan
├── inc/devkit/       # Headers (.hpp) públicos de la librería
├── src/             # Implementación (.cpp) de la librería devkit_shapes
├── app/             # Driver ejecutable (main.cpp), consume la librería
├── test/            # Tests (GoogleTest + GoogleMock)
├── test_package/    # Validación del paquete Conan (conan create)
├── version/          # Template version.h.in
├── docs/            # Salida de Doxygen (generado, no versionado)
├── coverage/        # Salida de gcovr (generado, no versionado)
├── bin/             # Binarios (debug/, release/, test/) (generado, no versionado)
├── temp/            # Artefactos de build (generado, no versionado)
├── scripts/         # Scripts auxiliares (configure.sh, release.sh)
├── .github/          # GitHub Actions (CI)
├── .clangd, .clang-format, .clang-tidy
├── CMakeLists.txt, CMakePresets.json
├── conanfile.py
└── CHANGELOG.md
```

---

## 4. Flujos de trabajo (día a día)

### 4.1. Debug (desarrollo normal)

```bash
./scripts/configure.sh debug      # solo la primera vez, o si cambias dependencias/Conan
cmake --build --preset debug
ctest --preset debug --output-on-failure
```

Incluye: warnings estrictos, sanitizers (ASan + UBSan), clang-tidy y símbolos de debug completos.

Para iterar rápido tras el primer `configure`:

```bash
cmake --build --preset debug && ctest --preset debug --output-on-failure
```

Ejecutar/depurar un test concreto:

```bash
./bin/debug/devkit_tests --gtest_filter=CircleTest.*
gdb --args ./bin/debug/devkit_tests --gtest_filter=RectangleTest.AreaIsComputedCorrectly
```

### 4.2. Release

```bash
./scripts/configure.sh release
cmake --build --preset release
ctest --build-config Release --test-dir temp/build/release --output-on-failure
```

Incluye: `-O3`, LTO, símbolos separados (`bin/release/devkit_tests` + `devkit_tests.debug`), sin sanitizers ni análisis estático.

### 4.3. Cppcheck (análisis estático, bajo demanda)

```bash
cmake --build temp/build/debug --target cppcheck
```

### 4.4. Coverage

```bash
./scripts/configure.sh coverage
cmake --build temp/build/coverage
ctest --test-dir temp/build/coverage --output-on-failure
cmake --build temp/build/coverage --target coverage
```

Abre `coverage/index.html` desde el **host** (el volumen está montado, no hace falta copiar nada).

### 4.5. Valgrind (memcheck)

```bash
./scripts/configure.sh valgrind
cmake --build temp/build/valgrind
cmake --build temp/build/valgrind --target memcheck
```

### 4.6. Documentación (Doxygen)

```bash
./scripts/configure.sh debug
cmake --preset debug -DDEVKIT_BUILD_DOCS=ON
cmake --build temp/build/debug --target docs
```

Abre `docs/html/index.html` desde el host.

### 4.7. Formato

```bash
# Verificar (lo que corre en CI)
find inc src app test -name "*.hpp" -o -name "*.cpp" | xargs clang-format --dry-run --Werror

# Aplicar automáticamente
find inc src app test -name "*.hpp" -o -name "*.cpp" | xargs clang-format -i
```

### 4.8. IWYU (include-what-you-use, puntual)

```bash
cmake --preset debug -DENABLE_IWYU=ON
cmake --build --preset debug
```

---

## 5. Por qué siempre hay que usar `scripts/configure.sh`

`cmake --preset <preset>` **no** ejecuta `conan install` por sí solo. Cada preset (`debug`, `release`, `coverage`, `valgrind`) usa su propia carpeta de build (`temp/build/<preset>/`) con su propio `conan_toolchain.cmake`, que Conan debe generar **antes** de que CMake pueda leerlo. `scripts/configure.sh <preset>` hace ambos pasos en el orden correcto:

```bash
./scripts/configure.sh <debug|release|coverage|valgrind> [default|gcc|clang]
```

El segundo argumento (opcional, por defecto `default`) permite elegir el compilador:

```bash
./scripts/configure.sh debug              # perfil 'default' autodetectado (actualmente GCC)
./scripts/configure.sh debug gcc          # fuerza el perfil conan/profiles/fedora-gcc
./scripts/configure.sh debug clang        # fuerza el perfil conan/profiles/fedora-clang
./scripts/configure.sh release clang      # también funciona combinado con cualquier preset
```

> Antes de forzar `gcc`/`clang`, verifica que `conan/profiles/fedora-gcc` y `conan/profiles/fedora-clang` tengan el `compiler.version` correcto para tu imagen (`gcc --version` / `clang --version` dentro del contenedor) — si no coincide, Conan fallará con `Invalid setting`. Si además usas una versión de compilador no incluida en el catálogo de Conan, añádela también a `conan/settings_user.yml` (ver sección 8).

Al cambiar de compilador es recomendable limpiar el build previo, ya que los artefactos de un compilador no son compatibles con los del otro:

```bash
rm -rf temp/build
./scripts/configure.sh debug clang
```

Solo hace falta volver a ejecutar `configure.sh` si:
- Cambias `conanfile.py` (nueva dependencia, cambio de versión, etc.)
- Borras `temp/build/`
- Cambias de compilador (`gcc` ↔ `clang` ↔ `default`)
- Es la primera vez que usas ese preset

Para simplemente recompilar tras editar código, basta con `cmake --build --preset <preset>`.

---

## 6. Cómo modificar la configuración del proyecto

### 6.1. Cambiar el estándar de C++

### Ruta: `CMakeLists.txt` (raíz)

```cmake
set(CMAKE_CXX_STANDARD 20)   # cambia a 17, 23, etc.
```

Después, reconfigura desde cero:

```bash
rm -rf temp/build
./scripts/configure.sh debug
```

> Si subes de estándar (por ejemplo a C++23), verifica que la versión de Clang/GCC instalada en el `Dockerfile` lo soporte, y que las dependencias de Conan (`fmt`, `gtest`) tengan un binario compatible con ese `compiler.cppstd` (si no, Conan las recompilará desde fuente automáticamente).

### 6.2. Añadir o quitar warnings

### Ruta: `cmake/CompilerWarnings.cmake`

Edita la lista `CLANG_GCC_WARNINGS` dentro de `devkit_set_project_warnings()`:

```cmake
set(CLANG_GCC_WARNINGS
    -Wall
    -Wextra
    -Wpedantic
    # ... añade o quita flags aquí
)
```

Los flags exclusivos de GCC (`-Wduplicated-cond`, `-Wlogical-op`, etc.) están en el bloque `elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")` — si añades un flag exclusivo de un compilador, ponlo en el bloque correspondiente (`Clang` o `GNU`), no en la lista común, o clang-tidy lo rechazará como "unknown warning option" (ya mitigado globalmente con `--extra-arg=-Wno-unknown-warning-option` en `StaticAnalyzers.cmake`, pero es más limpio evitarlo desde el origen).

Para convertir todos los warnings en errores (o dejar de hacerlo), busca `-Werror` en la misma función.

### 6.3. Añadir, quitar o cambiar optimizaciones de Release

### Ruta: `cmake/Optimizations.cmake`

```cmake
set(SAFE_OPTIMIZATION_FLAGS
    -O3
    -DNDEBUG
    -fomit-frame-pointer
    -funroll-loops
    # añade aquí, solo flags que NO alteren la semántica del programa
)
```

**Evita** añadir `-ffast-math`, `-funsafe-math-optimizations` o `-march=native` — rompen precisión IEEE754 o portabilidad del binario (ver comentarios en el propio fichero para el razonamiento completo).

### 6.4. Activar/desactivar sanitizers

### Ruta: `cmake/Sanitizers.cmake`

Controlado por la opción `ENABLE_SANITIZERS` (por defecto `ON` en Debug). Para usar ThreadSanitizer en vez de ASan+UBSan:

```bash
cmake --preset debug -DENABLE_THREAD_SANITIZER=ON
```

### 6.5. Añadir una nueva librería de terceros (Conan)

1. Busca el paquete en [ConanCenter](https://conan.io/center) para confirmar nombre y versión exacta.

2. Añádelo en `conanfile.py`:

   ### Ruta: `conanfile.py`

   ```python
   def requirements(self):
       self.requires("fmt/11.0.2")
       self.requires("nlohmann_json/3.11.3")   # <-- nueva dependencia
   ```

   Si es una dependencia **solo para tests** (no para producción), va en `build_requirements()` con `self.test_requires(...)` en vez de `requirements()`.

3. Si el paquete tiene opciones relevantes (por ejemplo `shared`), añádelas en `configure()`:

   ```python
   def configure(self):
       self.options["fmt"].shared = False
       self.options["nlohmann_json"].shared = False
   ```

4. Enlázala al target que la necesite (`src/CMakeLists.txt`, `app/CMakeLists.txt` o `test/CMakeLists.txt`):

   ```cmake
   find_package(nlohmann_json REQUIRED)   # en el CMakeLists.txt raíz, junto a find_package(fmt REQUIRED)

   target_link_libraries(devkit_shapes
       PRIVATE
           fmt::fmt
           nlohmann_json::nlohmann_json
   )
   ```

   Usa `PRIVATE` si la dependencia solo se usa en los `.cpp` (no se expone en ningún `.hpp` público de `inc/`), o `PUBLIC` si tipos de esa librería aparecen en la interfaz pública de tus headers.

5. Reconfigura (Conan detecta el cambio en `conanfile.py` y descarga/compila la nueva dependencia):

   ```bash
   rm -rf temp/build
   ./scripts/configure.sh debug
   ```

### 6.6. Añadir un nuevo `.cpp`/`.hpp` a la librería

1. Header en `inc/devkit/nuevo.hpp`, implementación en `src/nuevo.cpp`.
2. Añade el `.cpp` a la lista de fuentes en `src/CMakeLists.txt`:

   ```cmake
   add_library(devkit_shapes STATIC
       circle.cpp
       rectangle.cpp
       shape_printer.cpp
       nuevo.cpp   # <-- añadir
   )
   ```

3. Recompila (no hace falta `configure.sh`, solo build):

   ```bash
   cmake --build --preset debug
   ```

### 6.7. Añadir código al ejecutable (`app/`)

Añade el `.cpp` a `add_executable` en `app/CMakeLists.txt`:

```cmake
add_executable(devkit_app
    main.cpp
    nuevo_fichero.cpp
)
```

Si ese fichero necesita una dependencia nueva (de Conan o de `inc/`), añádela en el `target_link_libraries(devkit_app PRIVATE ...)` del mismo fichero.

### 6.8. Añadir nuevos tests

Crea `test/nuevo_test.cpp` y añádelo a `test/CMakeLists.txt`:

```cmake
add_executable(devkit_tests
    circle_test.cpp
    rectangle_test.cpp
    shape_printer_test.cpp
    shape_mock_test.cpp
    nuevo_test.cpp   # <-- añadir
)
```

### 6.9. Cambiar el compilador por defecto (GCC ↔ Clang)

`scripts/configure.sh` acepta un segundo argumento para elegir el compilador (ver sección 5):

```bash
rm -rf temp/build
./scripts/configure.sh debug clang    # o 'gcc' para forzar GCC explícitamente
```

Antes de usarlo, verifica que `conan/profiles/fedora-clang` (o `fedora-gcc`) tenga la versión de compilador correcta (`compiler.version=...`) — debe coincidir con lo que reporta `clang --version` / `gcc --version` dentro del contenedor. Si la versión instalada no está en el catálogo interno de Conan, añádela también a `conan/settings_user.yml`.

### 6.10. Cambiar el estilo de formato (`.clang-format`) o las reglas de `clang-tidy`

- Estilo de formato: edita `.clang-format` en la raíz (actualmente basado en Google Style con ajustes).
- Reglas de análisis: edita `.clang-tidy` — la sección `Checks:` controla qué categorías se activan/desactivan, y `CheckOptions:` controla convenciones de nombres (`CamelCase`, `lower_case`, etc.).

Tras cualquier cambio en `.clang-tidy`, no hace falta reconfigurar CMake, solo recompilar:

```bash
cmake --build --preset debug
```

---

## 7. Reutilizar `devkit_shapes` en otro proyecto

La librería (`devkit_shapes`, expuesta como `devkit::shapes`) está preparada para ser consumida de cuatro formas distintas. Elige según el caso.

### 7.1. Monorepo / mismo árbol de CMake (`add_subdirectory`)

Si `devkit/` vive como subcarpeta de un proyecto más grande:

```cmake
add_subdirectory(devkit)
target_link_libraries(mi_app PRIVATE devkit::shapes)
```

No requiere nada adicional — el `ALIAS devkit::shapes` ya existe en `src/CMakeLists.txt`.

### 7.2. `FetchContent` (otro repo Git, sin gestor de paquetes)

```cmake
include(FetchContent)
FetchContent_Declare(
    devkit
    GIT_REPOSITORY https://github.com/tu-usuario/devkit.git
    GIT_TAG        v0.1.0
)
FetchContent_MakeAvailable(devkit)

add_executable(mi_app main.cpp)
target_link_libraries(mi_app PRIVATE devkit::shapes)
```

Por defecto, si `devkit` no es el proyecto top-level, `DEVKIT_BUILD_TESTS` y `DEVKIT_BUILD_APP` se desactivan automáticamente (no hace falta que el consumidor los apague a mano), y `CMAKE_CXX_STANDARD` respeta el que ya haya fijado el proyecto padre si existe.

### 7.3. `cmake --install` (sin Conan)

```bash
# Dentro del contenedor, en devkit/
cmake --preset release -DDEVKIT_BUILD_TESTS=OFF -DDEVKIT_BUILD_APP=OFF
cmake --build --preset release
cmake --install temp/build/release --prefix /ruta/de/instalacion
```

Desde el otro proyecto:

```cmake
find_package(devkit REQUIRED PATHS /ruta/de/instalacion)
target_link_libraries(mi_app PRIVATE devkit::shapes)
```

### 7.4. Paquete Conan (`conan create` + `test_package`)

`devkit/conanfile.py` es una receta **dual**: sirve tanto para instalar tus propias dependencias (`fmt`, `gtest`) durante el desarrollo local, como para empaquetar `devkit_shapes` como un paquete Conan consumible por terceros. La distinción se resuelve automáticamente vía el flag `-c user.devkit:local_dev=True` que `scripts/configure.sh` ya pasa por ti — no hace falta que lo gestiones manualmente en el día a día.

Construir y validar el paquete localmente:

```bash
conan create . --build=missing
```

Esto compila `devkit_shapes` (sin `app/` ni `test/`), lo empaqueta, y ejecuta `test_package/` — un consumidor de prueba que hace `find_package(devkit)` y verifica que `devkit::shapes` funciona correctamente. Si termina sin errores, el paquete es válido.

Cómo lo usaría otro proyecto (una vez publicado en un remote):

```python
# conanfile.py del otro proyecto
def requirements(self):
    self.requires("devkit/0.1.0")
```
```cmake
find_package(devkit REQUIRED)
target_link_libraries(mi_app PRIVATE devkit::shapes)
```

**Publicar el paquete para que otros lo descarguen** requiere subirlo a un remote (no basta con `conan create`, que solo lo deja en tu caché local):

```bash
conan remote add mi-remote https://mi-artifactory.com/artifactory/api/conan/mi-repo
conan upload devkit/0.1.0 -r mi-remote --confirm
```

> ConanCenter (el remote público oficial) no es adecuado para este proyecto: está pensado para librerías de terceros con un ciclo de vida estable, no para plantillas de proyecto. Si necesitas distribución pública gratuita sin montar infraestructura propia, `FetchContent` sobre un tag de Git (sección 7.2) es la vía más simple; para uso interno en una organización, un remote propio (Artifactory, Cloudsmith, etc.) es la opción recomendada.

---

## 8. Cómo actualizar la versión correctamente

Este proyecto sigue [Versionado Semántico](https://semver.org/lang/es/) (`MAJOR.MINOR.PATCH`):

- **PATCH** (`0.1.0` → `0.1.1`): corrección de bugs, sin cambios en la API pública.
- **MINOR** (`0.1.0` → `0.2.0`): añades funcionalidad nueva (p. ej. una clase `Triangle`) sin romper código existente.
- **MAJOR** (`0.1.0` → `1.0.0`): cambias la API pública de forma incompatible.

Tanto `write_basic_package_version_file(... COMPATIBILITY SameMajorVersion)` (CMake) como cualquier consumidor de Conan que fije un rango de versión asumen que sigues este esquema — no es opcional si otros dependen de tu librería.

### 8.1. Dónde vive el número de versión

Hay **dos** sitios que deben mantenerse sincronizados manualmente (CMake no puede leer el `conanfile.py` y viceversa):

| Fichero | Línea |
|---|---|
| `CMakeLists.txt` | `project(devkit VERSION 0.1.0 ...)` |
| `conanfile.py` | `version = "0.1.0"` |

Todo lo demás se deriva automáticamente de `CMakeLists.txt`: `devkit::version::kVersionString` (vía `version/version.h.in`), la versión mostrada en Doxygen, y `devkitConfigVersion.cmake`.

### 8.2. Flujo recomendado al publicar una nueva versión

```bash
# 1. Actualiza el número en AMBOS ficheros:
#    - CMakeLists.txt → project(... VERSION 0.2.0 ...)
#    - conanfile.py    → version = "0.2.0"

# 2. Verifica que todo compila y los tests pasan con la nueva versión
rm -rf temp/build
./scripts/configure.sh debug
cmake --build --preset debug
ctest --preset debug --output-on-failure

# 3. Verifica que el paquete Conan también se construye y valida correctamente
conan create . --build=missing

# 4. Actualiza CHANGELOG.md (mueve las entradas de [Unreleased] a la nueva versión)

# 5. Commit, tag y push — el tag DEBE coincidir con la versión (prefijo 'v')
git add CMakeLists.txt conanfile.py CHANGELOG.md
git commit -m "Bump version to 0.2.0"
git tag -a v0.2.0 -m "Release 0.2.0"
git push origin main --tags

# 6. Si distribuyes vía Conan a un remote propio:
conan upload devkit/0.2.0 -r mi-remote --confirm
```

El tag `v0.2.0` es lo que un consumidor externo usará en `FetchContent`:

```cmake
FetchContent_Declare(
    devkit
    GIT_REPOSITORY https://github.com/tu-usuario/devkit.git
    GIT_TAG        v0.2.0
)
```

### 8.3. Usa `scripts/release.sh` para evitar desincronizar los dos ficheros

En vez de editar `CMakeLists.txt` y `conanfile.py` a mano (fácil olvidar uno de los dos), usa el script auxiliar:

```bash
./scripts/release.sh 0.2.0
```

Esto actualiza ambos ficheros de forma atómica. Después, sigue desde el paso 4 del flujo anterior (`CHANGELOG.md`, commit, tag, push).

### 8.4. `CHANGELOG.md`

El proyecto mantiene un `CHANGELOG.md` en la raíz siguiendo [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/). Cada cambio relevante se anota primero bajo `[Unreleased]`, y al hacer un release esa sección se renombra con la versión y fecha correspondientes, dejando `[Unreleased]` vacío para el siguiente ciclo.

### 8.5. Errores comunes a evitar

- **Tag sin actualizar `project(VERSION ...)`**: un consumidor que use `GIT_TAG v0.2.0` obtendría código correcto, pero `devkit::version::kVersionString` seguiría reportando la versión antigua — inconsistencia silenciosa. Usa `scripts/release.sh` para evitarlo.
- **Cambiar la API pública sin subir el MAJOR**: rompe a cualquier consumidor que fije `devkit/[>=0.1.0 <1.0.0]` en su `conanfile.py`, ya que confían en que los minors son compatibles hacia atrás.
- **Olvidar `conan create . --build=missing` antes de publicar**: si el `CMakeLists.txt` cambió de forma incompatible con el empaquetado (por ejemplo, un nuevo `.cpp` no añadido a `install()`), solo este comando lo detecta antes de subir el paquete a un remote.

---



Si necesitas una herramienta nueva del sistema (por ejemplo, otro compilador, un profiler distinto, etc.):

1. Añádela a la lista de `dnf install` en `docker/Dockerfile`.
2. Si es un paquete de Python (como `conan`/`gcovr`), añádela con versión fijada en `docker/requirements.txt`.
3. Reconstruye la imagen:

   ```bash
   docker-compose -f docker/docker-compose.yml down
   docker-compose -f docker/docker-compose.yml build
   docker-compose -f docker/docker-compose.yml up -d
   docker-compose -f docker/docker-compose.yml exec dev-env bash
   ```

> **Importante:** cualquier instalación hecha en caliente dentro del contenedor (`sudo dnf install ...` mientras estás dentro) se pierde al reconstruir la imagen. Si algo funciona probándolo así, siempre hay que trasladarlo también al `Dockerfile` para que quede persistente.

---

## 9. Añadir nuevas herramientas al entorno (Dockerfile)

Si necesitas una herramienta nueva del sistema (por ejemplo, otro compilador, un profiler distinto, etc.):

1. Añádela a la lista de `dnf install` en `docker/Dockerfile`.
2. Si es un paquete de Python (como `conan`/`gcovr`), añádela con versión fijada en `docker/requirements.txt`.
3. Reconstruye la imagen:

   ```bash
   docker-compose -f docker/docker-compose.yml down
   docker-compose -f docker/docker-compose.yml build
   docker-compose -f docker/docker-compose.yml up -d
   docker-compose -f docker/docker-compose.yml exec dev-env bash
   ```

> **Importante:** cualquier instalación hecha en caliente dentro del contenedor (`sudo dnf install ...` mientras estás dentro) se pierde al reconstruir la imagen. Si algo funciona probándolo así, siempre hay que trasladarlo también al `Dockerfile` para que quede persistente.

---

## 10. Resolución de problemas comunes

| Síntoma | Causa habitual | Solución |
|---|---|---|
| `Permission denied` al hacer `ls` dentro del contenedor | SELinux bloqueando el bind mount | Verifica que `docker-compose.yml` monte el proyecto con `:z` (`..:/home/dev/project:z`) |
| `Could not find toolchain file: conan_toolchain.cmake` | Ejecutaste `cmake --preset X` sin haber corrido `conan install` antes | Usa `./scripts/configure.sh X` en vez de `cmake --preset X` directamente |
| Un cambio en un fichero de configuración (Dockerfile, perfiles Conan, `.clang-tidy`...) no se refleja tras reconstruir | Caché de `docker-compose build` usando `buildx bake` | Asegúrate de que existe `docker/.env` con `COMPOSE_BAKE=false`; si persiste, `docker buildx prune -a -f` |
| `Invalid setting 'XX' is not a valid 'settings.compiler.version'` en `conan install` | La versión del compilador del sistema es más reciente que el catálogo interno de Conan | Añade la versión a `conan/settings_user.yml` |
| `cannot find libasan.so`/`libubsan.so` al linkar en Debug | Falta el paquete de runtime de sanitizers | Instala `libasan`, `libubsan`, `libtsan` en el `Dockerfile` |
| `undefined reference` al linkar en Release, pese a que el símbolo existe en la librería | `strip`/`objcopy` aplicado sobre una biblioteca estática (`.a`) con LTO | La separación de símbolos de debug (`cmake/Optimizations.cmake`) debe excluir targets `STATIC_LIBRARY` — solo aplica a ejecutables/`.so` |
| `unknown warning option` en clang-tidy sobre flags como `-Wduplicated-cond` | clang-tidy usa su propio front-end de Clang, no reconoce flags exclusivos de GCC | Ya mitigado con `--extra-arg=-Wno-unknown-warning-option` en `cmake/StaticAnalyzers.cmake` |
| `CMake Error: No se permiten builds in-source` al ejecutar `conan create .` | `conanfile.py` sin `layout()`, o `layout()` mal configurado, hace coincidir source y build folder | Usa `cmake_layout(self)` en `layout()`, condicionado a que no se haya pasado `-c user.devkit:local_dev=True` (ver sección 7.4) |
| Rutas de build duplicadas (`temp/build/debug/temp/build/Debug/...`) al ejecutar `scripts/configure.sh` | `layout()` del `conanfile.py` interfiere con `--output-folder` | Añade el flag `-c user.devkit:local_dev=True` en `scripts/configure.sh` y haz que `layout()` retorne temprano si esa conf está presente |

---

## 11. Referencia rápida de comandos

```bash
# Entorno
docker-compose -f docker/docker-compose.yml up -d
docker-compose -f docker/docker-compose.yml exec dev-env bash

# Debug
./scripts/configure.sh debug && cmake --build --preset debug && ctest --preset debug --output-on-failure

# Debug forzando compilador
rm -rf temp/build && ./scripts/configure.sh debug clang

# Release
./scripts/configure.sh release && cmake --build --preset release && ctest --build-config Release --test-dir temp/build/release --output-on-failure

# Análisis / calidad
cmake --build temp/build/debug --target cppcheck
find inc src app test -name "*.hpp" -o -name "*.cpp" | xargs clang-format --dry-run --Werror

# Coverage
./scripts/configure.sh coverage && cmake --build temp/build/coverage && ctest --test-dir temp/build/coverage && cmake --build temp/build/coverage --target coverage

# Valgrind
./scripts/configure.sh valgrind && cmake --build temp/build/valgrind && cmake --build temp/build/valgrind --target memcheck

# Documentación
cmake --preset debug -DDEVKIT_BUILD_DOCS=ON && cmake --build temp/build/debug --target docs

# Ejecutar el binario
./bin/debug/devkit
```