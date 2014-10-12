#!/usr/bin/env bash

# Returns 0 if the current directory is a Git repository.
function git::repo?() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Returns 0 if the current directory is the .git directory of a Git repository
function git::dot_dir?() {
  [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == "true" ]
}

# Returns 0 if the Git working tree has uncommitted changes.
function git::uncommitted_changes?() {
  ! git diff --quiet --ignore-submodules --cached
}

# Returns 0 if the Git working tree has unstaged files.
function git::unstaged_files?() {
  ! git diff-files --quiet --ignore-submodules --
}

# Returns 0 if the Git working tree has untracked files.
function git::untracked_files?() {
  [ -n "$(git ls-files --others --exclude-standard)" ]
}

# Returns 0 if the Git working tree has stashed files.
function git::stashed_files?() {
  git rev-parse --verify refs/stash >/dev/null 2>&1
}

# Returns the name of the current Git branch.
function git::branch_name() {
  git symbolic-ref --quiet --short HEAD 2> /dev/null || \
  git rev-parse --short HEAD 2> /dev/null || \
  echo "(unknown)"
}

# Returns the latest tag sorted by version.
function git::latest_tag() {
  local prefix=${1-v}
  local tag=$(
    git tag --list --sort=-v:refname "${prefix}*" | \
    sed -E -n '/[0-9]+(\.[0-9]+){2}/p' | \
    head -n1
  )

  [ -n "${tag}" ] && echo "$tag"
}
