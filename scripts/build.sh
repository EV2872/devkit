#!/usr/bin/env bash
# ============================================================
# Driver de build/ejecución del proyecto devkit
#
# Uso:
#   ./scripts/build.sh -build <config>[,<config>...] [opciones]
#   ./scripts/build.sh -exec  <config> [-- args-del-programa]
#
# Configs válidas: debug, release, test
#
# Opciones de -build:
#   --std=<17|20|23|26>       Estándar de C++ (default: 26)
#   --compiler=<clang|gcc>    Compilador a usar (default: clang)
#   --coverage                Solo aplica a 'test': genera reporte en coverage/
#
# Ejemplos:
#   ./scripts/build.sh -build debug
#   ./scripts/build.sh -build test,release --compiler=gcc
#   ./scripts/build.sh -build test --coverage
#   ./scripts/build.sh -exec release
#   ./scripts/build.sh -exec test -- --algun-arg
# ============================================================
set -euo pipefail

PROJECT_NAME="devkit"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

STD="26"
COMPILER="clang"
DO_COVERAGE="OFF"
ACTION=""
TARGETS=""
EXTRA_ARGS=""

usage() {
    sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
    exit 1
}

[[ $# -eq 0 ]] && usage

while [[ $# -gt 0 ]]; do
    case "$1" in
        -build)
            ACTION="build"
            TARGETS="${2:?Falta indicar config(s), ej: -build debug}"
            shift 2
            ;;
        -exec)
            ACTION="exec"
            TARGETS="${2:?Falta indicar config, ej: -exec release}"
            shift 2
            ;;
        --std=*)
            STD="${1#*=}"
            shift
            ;;
        --compiler=*)
            COMPILER="${1#*=}"
            shift
            ;;
        --coverage)
            DO_COVERAGE="ON"
            shift
            ;;
        --)
            shift
            EXTRA_ARGS="$*"
            break
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Argumento desconocido: $1"
            usage
            ;;
    esac
done

[[ -z "$ACTION" ]] && usage

case "$COMPILER" in
    clang) CXX_COMPILER="clang++" ;;
    gcc)   CXX_COMPILER="g++" ;;
    *)
        echo "Compilador desconocido: '$COMPILER' (usa 'clang' o 'gcc')"
        exit 1
        ;;
esac

cmake_build_type_of() {
    case "$1" in
        debug)   echo "Debug" ;;
        release) echo "Release" ;;
        test)    echo "Test" ;;
        *)
            echo "Configuración desconocida: '$1' (usa debug|release|test)" >&2
            exit 1
            ;;
    esac
}

build_one() {
    local cfg="$1"
    local cmake_build_type
    cmake_build_type="$(cmake_build_type_of "$cfg")"

    local build_dir="${ROOT_DIR}/auxiliar/${cfg}"
    mkdir -p "${build_dir}"

    echo "==> [${cfg}] Instalando dependencias con Conan..."
    conan install "${ROOT_DIR}/conan" \
        --output-folder="${build_dir}" \
        --build=missing \
        -s build_type="${cmake_build_type}"

    echo "==> [${cfg}] Configurando con CMake (${CXX_COMPILER}, C++${STD})..."
    cmake -S "${ROOT_DIR}" -B "${build_dir}" -G Ninja \
        -DCMAKE_BUILD_TYPE="${cmake_build_type}" \
        -DCMAKE_CXX_COMPILER="${CXX_COMPILER}" \
        -DPROJECT_CXX_STANDARD="${STD}" \
        -DCMAKE_TOOLCHAIN_FILE="${build_dir}/conan_toolchain.cmake"

    echo "==> [${cfg}] Compilando..."
    cmake --build "${build_dir}" --parallel

    if [[ "$cfg" == "test" ]]; then
        echo "==> [test] Ejecutando tests (ctest)..."
        ctest --test-dir "${build_dir}" --output-on-failure

        if [[ "$DO_COVERAGE" == "ON" ]]; then
            echo "==> [test] Generando cobertura en coverage/..."
            cmake --build "${build_dir}" --target coverage
        fi
    fi

    echo "==> [${cfg}] OK -> bin/${PROJECT_NAME}_${cfg}"
}

exec_one() {
    local cfg="$1"
    local bin="${ROOT_DIR}/bin/${PROJECT_NAME}_${cfg}"

    if [[ ! -x "$bin" ]]; then
        echo "No existe '${bin}'. Compílalo primero con: $0 -build ${cfg}"
        exit 1
    fi

    echo "==> Ejecutando ${bin}"
    # shellcheck disable=SC2086
    "${bin}" ${EXTRA_ARGS}
}

IFS=',' read -ra CONFIGS <<< "$TARGETS"

for cfg in "${CONFIGS[@]}"; do
    case "$ACTION" in
        build) build_one "$cfg" ;;
        exec)  exec_one  "$cfg" ;;
    esac
done
