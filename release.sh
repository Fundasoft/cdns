#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

bump="${1:-patch}"

case "$bump" in
  patch|minor|major) ;;
  *)
    echo "uso: $0 [patch|minor|major]   (default: patch)"
    exit 1
    ;;
esac

current="$(git tag --sort=-v:refname | head -1)"
current="${current:-0.0.0}"

IFS='.' read -r major minor patch <<< "$current"

case "$bump" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
esac

version="$major.$minor.$patch"
branch="$(git rev-parse --abbrev-ref HEAD)"

git add .

if git diff --cached --quiet; then
  echo "No hay cambios para publicar (nada agregado desde $current)."
  exit 1
fi

git commit -m "release $version"
git push origin "$branch"
git tag "$version"
git push origin "$version"

echo "Publicado $version"
