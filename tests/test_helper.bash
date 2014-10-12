#!/usr/bin/env bash

source lib/git.sh
source lib/utils.sh

setup() {
  mkdir "${BATS_TMPDIR}/dotfiles_tests"
  cd "${BATS_TMPDIR}/dotfiles_tests"
}

teardown() {
  rm -rf "${BATS_TMPDIR}/dotfiles_tests"
}
