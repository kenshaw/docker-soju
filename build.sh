#!/bin/bash
# Builds the image and pushes it to Docker Hub as :latest, :<soju version> and :<date>.
# Needs `buildah login docker.io` (or `podman login docker.io`: the same file, ~/.config/containers/auth.json) done once.
# `./build.sh --no-push` builds only.
set -euo pipefail

cd "$(dirname "$0")"

image="${IMAGE:-docker.io/kenshaw/soju}"
push=1
[ "${1:-}" = "--no-push" ] && push=0

if [ "$push" = 1 ] && ! buildah login --get-login docker.io >/dev/null 2>&1; then
  echo "not logged in to docker.io: run 'buildah login docker.io' first" >&2
  exit 1
fi

# --pull=newer gets a newer Alpine base, --no-cache makes `apk add` fetch the newest soju.
buildah build --platform linux/amd64 --pull=newer --no-cache --tag "$image:latest" .

# soju has no -version flag, so ask the package manager: `apk list --installed soju` prints "soju-0.10.1-r8 x86_64 {soju} ...".
version="$(podman run --rm --platform linux/amd64 --entrypoint apk "$image:latest" list --installed soju | awk 'NR == 1 {print $1}')"
version="${version#soju-}"
if ! [[ "$version" =~ ^[0-9][0-9A-Za-z._-]*$ ]]; then
  echo "could not read the soju version, got: $version" >&2
  exit 1
fi
date="$(date -u +%Y%m%d)"
echo "soju $version, built $date"

buildah tag "$image:latest" "$image:$version" "$image:$date"

if [ "$push" = 1 ]; then
  for tag in latest "$version" "$date"; do
    buildah push "$image:$tag"
  done
fi
