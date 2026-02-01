#!/usr/bin/env bash

set -o pipefail
set -e
set -x

source ./common.sh

NEW_VERSION=$1
REFERENCE_PKGBUILD="${git_root}/firmware/libasi/PKGBUILD"

################################################################################
function update_version() {
  local pkgbuild="${1}/PKGBUILD"
  local old_version="${2}"
  local new_version="${3}"
  local old_hash="${4}"
  local new_hash="${5}"
  local package_root="$(dirname "${pkgbuild}")"

  echo "Updating [${package_root}] to [${new_version}]"

  if [ "${old_version}" == "${new_version}" ]
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

if [ ! -f "v${NEW_VERSION}.tar.gz" ]; then
  wget "https://github.com/indilib/indi-3rdparty/archive/v${NEW_VERSION}.tar.gz"
fi

OLD_VERSION="$(grep "pkgver=" "${REFERENCE_PKGBUILD}" | cut -f2 -d'=')"
OLD_HASH="$(grep "sha256sums=" "${REFERENCE_PKGBUILD}" | cut -f2 -d'=' | tr -d '()"')"
NEW_HASH="$(sha256sum "v${NEW_VERSION}.tar.gz" | cut -f1 -d' ')"

foreach_dir update_version firmware "${OLD_VERSION}" "${NEW_VERSION}" "${OLD_HASH}" "${NEW_HASH}"
foreach_dir update_version drivers "${OLD_VERSION}" "${NEW_VERSION}" "${OLD_HASH}" "${NEW_HASH}"
