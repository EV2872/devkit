#!/usr/bin/env bash
# ==============================================================================
# release.sh
# Automatiza el bump de versión: actualiza CMakeLists.txt y conanfile.py de
# forma atómica, evitando que ambos ficheros queden desincronizados.
#
# Uso: ./scripts/release.sh <version>
# Ejemplo: ./scripts/release.sh 0.2.0
# ==============================================================================
set -euo pipefail

NEW_VERSION="${1:?Uso: ./scripts/release.sh <version>  (ej. 0.2.0)}"

if [[ ! "${NEW_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Formato de versión inválido: '${NEW_VERSION}'. Usa MAJOR.MINOR.PATCH (ej. 0.2.0)." >&2
    exit 1
fi

sed -i "s/VERSION [0-9]\+\.[0-9]\+\.[0-9]\+/VERSION ${NEW_VERSION}/" CMakeLists.txt
sed -i "s/version = \"[0-9]\+\.[0-9]\+\.[0-9]\+\"/version = \"${NEW_VERSION}\"/" conanfile.py

echo "✅ Versión actualizada a ${NEW_VERSION} en CMakeLists.txt y conanfile.py"
echo ""
echo "Siguientes pasos:"
echo "  1. Revisa el diff: git diff CMakeLists.txt conanfile.py"
echo "  2. Actualiza CHANGELOG.md (mueve [Unreleased] a [${NEW_VERSION}] - \$(date +%Y-%m-%d))"
echo "  3. Verifica que todo compila y pasa:"
echo "       rm -rf temp/build && ./scripts/configure.sh debug && cmake --build --preset debug && ctest --preset debug --output-on-failure"
echo "  4. Verifica el paquete Conan:"
echo "       conan create . --build=missing"
echo "  5. Commit, tag y push:"
echo "       git add CMakeLists.txt conanfile.py CHANGELOG.md"
echo "       git commit -m \"Bump version to ${NEW_VERSION}\""
echo "       git tag -a v${NEW_VERSION} -m \"Release ${NEW_VERSION}\""
echo "       git push origin main --tags"