#!/usr/bin/env bash

set -o pipefail
set -e
set -x

source ./common.sh

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
foreach_dir push firmware
foreach_dir push drivers 
