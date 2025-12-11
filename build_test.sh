#!/usr/bin/env bash

set -e
set -x

readonly git_root="$(git rev-parse --show-toplevel)"
readonly architecture="$(uname -m)"
readonly PKGFORMAT=$(grep PKGEXT /etc/makepkg.conf | cut -f2 -d"'")

################################################################################
function test_build() {
  local pkgname="${1}"
  pushd "${pkgname}"
  local version="$(grep "pkgver=" PKGBUILD | cut -f2 -d'=')"
  if ! grep -q "${architecture}" PKGBUILD; then
    echo "################################################################################"
    echo "# Building ${pkgname} skipped for ${architecture}"
    echo "################################################################################"
    return 0
  fi

  if ! ls | grep -q "${version}" | grep -q "${PKGFORMAT}"; then
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
for firmware in $(ls firmware | grep -v -f firmware/ignore); do
  test_build "${git_root}/firmware/${firmware}"
done

echo "################################################################################"
echo "# Installing Firmware packages"
echo "################################################################################"
sudo pacman -U $(find "${git_root}/firmware" -type f -name "*${PKGFORMAT}")

for driver in $(ls drivers | grep -v -f drivers/ignore); do
  test_build "${git_root}/drivers/${driver}"
done

echo "################################################################################"
echo "# Installing Driver packages"
echo "################################################################################"
sudo pacman -U $(find "${git_root}/drivers" -type f -name "*${PKGFORMAT}")
