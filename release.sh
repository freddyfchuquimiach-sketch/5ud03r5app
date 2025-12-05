#!/bin/bash
set -e

VERSION=$1
TAG="v$VERSION"

if [[ -z "$VERSION" ]]; then
  echo "Uso: ./release.sh 1-0-2"
  exit 1
fi

# Verificar que no haya cambios sin commit
if ! git diff-index --quiet HEAD --; then
  echo "ERROR: Hay cambios sin commit. Haz commit o stashing antes de continuar."
  exit 1
fi

# Verificar que el tag no exista
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "ERROR: El tag $TAG ya existe."
  exit 1
fi

echo "==> Iniciando release $TAG..."

# Asegurar develop actualizado
git checkout develop
git pull --rebase origin develop

# Asegurar main actualizado
git checkout main
git pull --rebase origin main

# Merge develop → main
echo "==> Merge develop → main..."
git merge --no-ff develop -m "release: $TAG"

# Crear tag
echo "==> Creando tag $TAG..."
git tag -a "$TAG" -m "Release $TAG"

# Push main y tag
echo "==> Subiendo main y tag..."
git push origin main
git push origin "$TAG"

# Sincronizar develop
echo "==> Sincronizando main → develop..."
git checkout develop
git merge main -m "chore: sincronizar release $TAG desde main"
git push origin develop

echo ""
echo "===================================="
echo " RELEASE $TAG COMPLETADO CON ÉXITO "
echo "===================================="
