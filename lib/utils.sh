#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

e_header() {
  printf "${COLOR_RESET}%s\n" "$@"
}

e_success() {
  printf "${COLOR_GREEN}✔ %s${COLOR_RESET}\n" "$@"
}

e_error() {
  printf "${COLOR_RED}x %s${COLOR_RESET}\n" "$@"
}

function semver::parse() {
  local re="\([a-zA-Z_-]\{1,\}\)\([0-9]\{1,\}\)[.]\([0-9]\{1,\}\)[.]\([0-9]\{1,\}\)"
  local str=$(echo "$@" | sed -n "s/${re}/\1 \2 \3 \4/p")
  [ -n "$str" ] && echo "$str"
}

function semver::increment_patch() {
  local parsed="$(semver::parse "${@}")"

  if [ -n "$parsed" ]; then
    read prefix major minor patch <<< "${parsed}"
    echo "${prefix}${major}.${minor}.$((patch + 1))"
  else
    return 1
  fi
}
