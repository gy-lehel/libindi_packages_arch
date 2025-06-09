#!/usr/bin/env bash

set -o pipefail
set -e
set -x

NEWVERSION=$1
readonly git_root="$(git rev-parse --show-toplevel)"

################################################################################
function update_version() {
  local pkgbuild=$1
  local package_root="$(dirname "${pkgbuild}")"
  local old_version="$(grep "pkgver=" "${pkgbuild}" | cut -f2 -d'=')"
  local new_version=$2
  local old_hash=$3
  local new_hash=$4

  pushd "${package_root}"
  git checkout master
  git pull --rebase origin master
  popd

  sed -e "s@${old_version}@${new_version}@g" -i "${pkgbuild}"
  sed -e "s@${old_hash}@${new_hash}@g" -i "${pkgbuild}"
}

################################################################################
if [ $# -ne 1 ]; then
  echo "$0 <new version>"
  exit 1
fi

OLD_HASH="$(grep "sha256sums=" "${git_root}/firmware/libasi/PKGBUILD" | cut -f2 -d'=' | tr -d '()"')"

if [ ! -f "v${NEWVERSION}.tar.gz" ]; then
  wget "https://github.com/indilib/indi-3rdparty/archive/v${NEWVERSION}.tar.gz"
fi
NEWHASH="$(sha256sum "v${NEWVERSION}.tar.gz" | cut -f1 -d' ')"

for firmware in $(ls firmware | grep -v -f firmware/ignore); do
  echo "Updating [${firmware}] to [${NEWVERSION}]"
  update_version "firmware/${firmware}/PKGBUILD" "${NEWVERSION}" "${OLD_HASH}" "${NEWHASH}"
done

for driver in $(ls drivers | grep -v -f drivers/ignore); do
  echo "Updating [${driver}] to [${NEWVERSION}]"
  update_version "drivers/${driver}/PKGBUILD" "${NEWVERSION}" "${OLD_HASH}" "${NEWHASH}"
done
