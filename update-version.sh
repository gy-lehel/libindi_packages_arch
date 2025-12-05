#!/usr/bin/env bash

set -o pipefail
set -e
set -x

NEWVERSION=$1
readonly git_root="$(git rev-parse --show-toplevel)"
readonly architecture="$(uname -m)"

################################################################################
function update_version() {
  local pkgbuild="${1}"
  local package_root="$(dirname "${pkgbuild}")"
  local old_version="$(grep "pkgver=" "${pkgbuild}" | cut -f2 -d'=')"
  local new_version="${2}"
  local old_hash="$(grep "sha256sums=" "${git_root}/firmware/libasi/PKGBUILD" | cut -f2 -d'=' | tr -d '()"')"
  local new_hash="${3}"

  if [ "${old_version}" == "${new_version}"]
  then
    return 0
  fi

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

if [ ! -f "v${NEWVERSION}.tar.gz" ]; then
  wget "https://github.com/indilib/indi-3rdparty/archive/v${NEWVERSION}.tar.gz"
fi
NEWHASH="$(sha256sum "v${NEWVERSION}.tar.gz" | cut -f1 -d' ')"

for firmware in $(ls firmware | grep -v -f firmware/ignore | grep -v -f "firmware/ignore.${architecture}"); do
  echo "Updating [${firmware}] to [${NEWVERSION}]"
  update_version "firmware/${firmware}/PKGBUILD" "${NEWVERSION}" "${NEWHASH}"
done

for driver in $(ls drivers | grep -v -f drivers/ignore | grep -v -f "drivers/ignore.${architecture}"); do
  echo "Updating [${driver}] to [${NEWVERSION}]"
  update_version "drivers/${driver}/PKGBUILD" "${NEWVERSION}" "${NEWHASH}"
done
