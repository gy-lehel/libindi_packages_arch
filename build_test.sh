#!/usr/bin/env bash

set -e

readonly git_root="$(git rev-parse --show-toplevel)"
readonly architecture="$(uname -m)"

################################################################################
function test_build() {
  local pkgname="${1}"
  pushd "${pkgname}"
  local version="$(grep "pkgver=" PKGBUILD | cut -f2 -d'=')"

  if ! ls | grep -q "${version}"
  then
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
for firmware in $(ls firmware | grep -v -f firmware/ignore | grep -v -f "firmware/ignore.${architecture}"); do
  test_build "${git_root}/firmware/${firmware}"
done

echo "################################################################################"
echo "# Installing Firmware packages"
echo "################################################################################"
sudo pacman -U $(find "${git_root}/firmware" -type f -name '*.zst')

for driver in $(ls drivers | grep -v -f drivers/ignore | grep -v -f "drivers/ignore.${architecture}"); do
  test_build "${git_root}/drivers/${driver}"
done

echo "################################################################################"
echo "# Installing Driver packages"
echo "################################################################################"
sudo pacman -U $(find "${git_root}/drivers" -type f -name '*.zst')
