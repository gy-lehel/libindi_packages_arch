#!/usr/bin/env bash

set -o pipefail
set -e
set -x

source ./common.sh

readonly PKGFORMAT=$(grep PKGEXT /etc/makepkg.conf | cut -f2 -d"'")

################################################################################
function test_build() {
  local pkgbuild="${1}/PKGBUILD"
  local package_root="$(dirname "${pkgbuild}")"

  pushd "${package_root}"
  local version="$(grep "pkgver=" PKGBUILD | cut -f2 -d'=')"
  if ! grep -q "${architecture}" PKGBUILD; then
    echo "################################################################################"
    echo "# Building ${pkgname} skipped for ${architecture}"
    echo "################################################################################"
    return 0
  fi

  if ! ls | grep -q "${version}"; then
    echo "################################################################################"
    echo "# Building ${pkgname}"
    echo "################################################################################"
    makepkg -srcf
    makepkg --printsrcinfo >.SRCINFO
  else
    echo "################################################################################"
    echo "# ${pkgname} is already built, skipping"
    echo "################################################################################"
  fi
  popd
}

################################################################################
foreach_dir test_build firmware

echo "################################################################################"
echo "# Installing Firmware packages"
echo "################################################################################"
sudo pacman -U $(find "${git_root}/firmware" -type f -name "*${PKGFORMAT}")

foreach_dir test_build drivers

echo "################################################################################"
echo "# Installing Driver packages"
echo "################################################################################"
sudo pacman -U $(find "${git_root}/drivers" -type f -name "*${PKGFORMAT}")
