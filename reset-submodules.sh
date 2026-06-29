#!/usr/bin/env bash

set -o pipefail
set -e
set -x

source ./common.sh

OLD_VERSION="${1}"
NEW_VERSION="${2}"
OLD_HASH="${3}"
REFERENCE_PKGBUILD="${git_root}/firmware/libasi/PKGBUILD"

################################################################################
function reset_submodule() {
  local submodule="${1}"

  pushd "${submodule}"

  git checkout master
  git pull --rebase --autostash origin master

  popd
}

################################################################################
git submodule deinit --all --force
git submodule update --init --recursive

foreach_dir reset_submodule firmware "${OLD_VERSION}" "${NEW_VERSION}" "${OLD_HASH}" "${NEW_HASH}"
foreach_dir reset_submodule drivers "${OLD_VERSION}" "${NEW_VERSION}" "${OLD_HASH}" "${NEW_HASH}"
