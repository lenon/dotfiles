#!/usr/bin/env bash

source lib/git.sh

setup() {
  mkdir "${BATS_TMPDIR}/dotfiles_tests"
  cd "${BATS_TMPDIR}/dotfiles_tests"
}

teardown() {
  rm -rf "${BATS_TMPDIR}/dotfiles_tests"
}
