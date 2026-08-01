#!/usr/bin/env bash
# ==============================================================================
# configure.sh
# Ejecuta conan install (genera el toolchain) y después cmake --preset,
# en el orden correcto — conan SIEMPRE antes de cmake, nunca al revés.
#
# Uso:
#   ./scripts/configure.sh <preset> [compilador]
#
#   <preset>      debug | release | coverage | valgrind   (default: debug)
#   [compilador]  default | gcc | clang                   (default: default)
#
# Ejemplos:
#   ./scripts/configure.sh debug              # preset debug, perfil Conan 'default' (autodetectado)
#   ./scripts/configure.sh debug clang         # preset debug, forzando el perfil 'fedora-clang'
#   ./scripts/configure.sh release gcc         # preset release, forzando el perfil 'fedora-gcc'
# ==============================================================================
set -euo pipefail

PRESET="${1:-debug}"
COMPILER="${2:-default}"

declare -A BUILD_TYPES=(
    [debug]="Debug"
    [release]="Release"
    [coverage]="Debug"
    [valgrind]="Debug"
)

declare -A COMPILER_PROFILES=(
    [gcc]="fedora-gcc"
    [clang]="fedora-clang"
)

BUILD_TYPE="${BUILD_TYPES[$PRESET]:-Debug}"
OUTPUT_DIR="temp/build/${PRESET}"

CONAN_PROFILE_ARGS=()
if [[ "${COMPILER}" != "default" ]]; then
    PROFILE_NAME="${COMPILER_PROFILES[${COMPILER}]:-}"
    if [[ -z "${PROFILE_NAME}" ]]; then
        echo "❌ Compilador desconocido: '${COMPILER}'. Usa 'default', 'gcc' o 'clang'." >&2
        exit 1
    fi
    CONAN_PROFILE_ARGS=(-pr:h="${PROFILE_NAME}")
    echo "==> Forzando perfil de compilador: ${PROFILE_NAME}"
fi

echo "==> conan install (preset=${PRESET}, build_type=${BUILD_TYPE}, compiler=${COMPILER})"
conan install . \
    --output-folder="${OUTPUT_DIR}" \
    --build=missing \
    -c user.devkit:local_dev=True \
    "${CONAN_PROFILE_ARGS[@]}" \
    -s build_type="${BUILD_TYPE}"

echo "==> cmake --preset ${PRESET}"
cmake --preset "${PRESET}"

echo "✅ Listo. Ahora puedes compilar con: cmake --build --preset ${PRESET}"