#!/usr/bin/env bash

set -o pipefail
set -e
set -x

source ./common.sh

################################################################################
function push() {
  pushd $1

  if ! grep -q "pkgver = ${new_version}" .SRCINFO
  then
    makepkg --printsrcinfo >.SRCINFO
  fi

  if [[ $(git status --porcelain --untracked-files=no | wc -l) -gt 0 ]]
  then
    local version="$(grep "pkgver=" "PKGBUILD" | cut -f2 -d'=')"
    git add -u
    git commit -m "v${version}"
  fi

  if ! git status | grep -q "Your branch is up to date with 'origin/master'."
  then
    git push
  fi
  popd
}

################################################################################
readonly VERSION="${1}"
foreach_dir push firmware
foreach_dir push drivers 
