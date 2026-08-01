#!/usr/bin/env bash
# Ejecuta clang-tidy y cppcheck sobre src/ e inc/, excluyendo STL/terceros.
# Requiere haber compilado antes 'debug' para tener compile_commands.json.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/auxiliar/debug"

if [[ ! -f "${BUILD_DIR}/compile_commands.json" ]]; then
    echo "No existe compile_commands.json en ${BUILD_DIR}."
    echo "Ejecuta primero: ./scripts/build.sh -build debug"
    exit 1
fi

echo "==> clang-tidy"
find "${ROOT_DIR}/src" "${ROOT_DIR}/inc" \( -name '*.cc' -o -name '*.hpp' \) -print0 \
    | xargs -0 clang-tidy -p "${BUILD_DIR}"

echo "==> cppcheck"
cmake --build "${BUILD_DIR}" --target cppcheck
