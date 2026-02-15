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
function update_version() {
  local pkgbuild="${1}/PKGBUILD"
  local old_version="${2}"
  local new_version="${3}"
  local old_hash="${4}"
  local new_hash="${5}"
  local package_root="$(dirname "${pkgbuild}")"

  if ! grep -q "pkgver=${new_version}" "${pkgbuild}"
  then
    echo "Updating [${package_root}] to [${new_version}]"

    if [ "${old_version}" == "${new_version}" ]
    then
      return 0
    fi

    pushd "${package_root}"
      git checkout master
#      git pull --rebase origin master
    popd

    sed -e "s@${old_version}@${new_version}@g" -i "${pkgbuild}"
    sed -e "s@${old_hash}@${new_hash}@g" -i "${pkgbuild}"
  else
    echo "Skipping [${package_root}] already at version [${new_version}]"
  fi
}

################################################################################
if [ $# -ne 3 ]; then
  echo "$0 <old_version> <new version> <old_hash>"
  exit 1
fi

if [ ! -f "v${NEW_VERSION}.tar.gz" ]; then
  wget "https://github.com/indilib/indi-3rdparty/archive/v${NEW_VERSION}.tar.gz"
fi

NEW_HASH="$(sha256sum "v${NEW_VERSION}.tar.gz" | cut -f1 -d' ')"

foreach_dir update_version firmware "${OLD_VERSION}" "${NEW_VERSION}" "${OLD_HASH}" "${NEW_HASH}"
foreach_dir update_version drivers "${OLD_VERSION}" "${NEW_VERSION}" "${OLD_HASH}" "${NEW_HASH}"
