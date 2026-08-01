#!/usr/bin/env bash
# Perfila un binario ya compilado con perf y heaptrack.
# Uso: ./scripts/profile.sh bin/devkit_release
set -euo pipefail

BIN="${1:?Uso: $0 <ruta-al-binario>}"

if [[ ! -x "$BIN" ]]; then
    echo "El binario '$BIN' no existe o no es ejecutable."
    exit 1
fi

echo "==> perf record + report"
perf record -g -o /tmp/devkit-perf.data -- "${BIN}"
perf report -i /tmp/devkit-perf.data

echo "==> heaptrack"
heaptrack "${BIN}"
