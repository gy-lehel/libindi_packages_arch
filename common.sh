#!/usr/bin/env bash

readonly git_root="$(git rev-parse --show-toplevel)"
readonly architecture="$(uname -m)"

foreach_dir()
{
  local func="${1}"
  shift
  local apply_to="${1}"
  shift

  for apply_path in $(ls "${git_root}/${apply_to}" | \
    grep -v -f "${git_root}/${apply_to}/ignore")
  do
    ${func} "${git_root}/${apply_to}/${apply_path}" ${@}
  done
}
