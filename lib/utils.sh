#!/usr/bin/env bash

source ./lib/colors.sh

e_header() {
  printf "${COLOR_RESET}%s\n" "$@"
}

e_success() {
  printf "${COLOR_GREEN}✔ %s${COLOR_RESET}\n" "$@"
}

e_error() {
  printf "${COLOR_RED}x %s${COLOR_RESET}\n" "$@"
}
