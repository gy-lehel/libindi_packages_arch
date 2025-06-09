#!/usr/bin/env bash

set -e

readonly git_root="$(git rev-parse --show-toplevel)"

################################################################################
function test_build() {
  pushd $1
  echo "################################################################################"
  echo "# Building ${1}"
  echo "################################################################################"
  makepkg -srcf
  makepkg --printsrcinfo >.SRCINFO
  popd
}

################################################################################
for firmware in $(ls firmware | grep -v -f firmware/ignore); do
  test_build "${git_root}/firmware/${firmware}"
done

echo "################################################################################"
echo "# Installing Firmware packages"
echo "################################################################################"
#sudo pacman -U $(find "${git_root}/firmware" -type f -name '*.zst')

for driver in $(ls drivers | grep -v -f drivers/ignore); do
  test_build "${git_root}/drivers/${driver}"
done

echo "################################################################################"
echo "# Installing Firmware packages"
echo "################################################################################"
sudo pacman -U $(find "${git_root}/drivers" -type f -name '*.zst')
