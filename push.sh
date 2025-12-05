#!/usr/bin/env bash

set -o pipefail
set -x

readonly git_root="$(git rev-parse --show-toplevel)"
readonly architecture="$(uname -m)"

################################################################################
function push() {
  pushd $1
  local version="$(grep "pkgver=" "PKGBUILD" | cut -f2 -d'=')"
  makepkg --printsrcinfo >.SRCINFO
  git add -u
  git commit -m "v${version}"
  git push
  popd
}

################################################################################
for firmware in $(ls firmware | grep -v -f firmware/ignore | grep -v -f "firmware/ignore.${architecture}"); do
  push "firmware/${firmware}"
done

for driver in $(ls drivers | grep -v -f drivers/ignore | grep -v -f "drivers/ignore.${architecture}"); do
  push "drivers/${driver}"
done
