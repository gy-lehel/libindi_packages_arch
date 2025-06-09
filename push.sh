#!/usr/bin/env bash

set -o pipefail
set -x

NEWVERSION=$1
readonly git_root="$(git rev-parse --show-toplevel)"

################################################################################
function push() {
  pushd $1
  local version="$(grep "pkgver=" "PKGBUILD" | cut -f2 -d'=')"
  git add -u
  git commit -m "v${version}"
  git push
  popd
}

################################################################################
for firmware in $(ls firmware | grep -v -f firmware/ignore); do
  push "firmware/${firmware}"
done

for driver in $(ls drivers | grep -v -f drivers/ignore); do
  push "drivers/${driver}"
done
