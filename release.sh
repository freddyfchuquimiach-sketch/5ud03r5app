#!/bin/bash
set -e

VERSION=$1
if [[ -z "$VERSION" ]]; then
  echo "Uso: ./release.sh 1.0.2"
  exit 1
fi

echo "Creando release v$VERSION..."

# 1. Asegurar que estamos limpios
git checkout develop
git pull origin develop
git checkout main
git pull origin main

# 2. Merge develop → main
git merge --no-ff develop -m "release: v$VERSION"

# 3. Crear tag
git tag -a "v$VERSION" -m "Release v$VERSION"

# 4. Subir main + tag
git push origin main
git push origin "v$VERSION"

# 5. ¡AUTOMÁTICO! Merge main → develop (lo que querías)
echo "Sincronizando main → develop..."
git checkout develop
git merge main -m "chore: sincronizar release v$VERSION desde main"
git push origin develop

echo ""
echo "¡RELEASE v$VERSION COMPLETADO!"
echo "   main  → v$VERSION + latest"
echo "   develop ← actualizado con el release"
echo "   Docker Hub → v$VERSION y latest actualizado en <2 min"
