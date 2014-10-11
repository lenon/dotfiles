#!/usr/bin/env bash

# Returns 0 if the current directory is a git repository.
is_a_git_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Returns 0 if the current directory is the .git directory.
is_dot_git() {
  [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == "true" ]
}

# Returns 0 if the working tree has uncommitted changes.
has_uncommitted_changes() {
  ! git diff --quiet --ignore-submodules --cached
}

# Returns 0 if the working tree has unstaged files.
has_unstaged_files() {
  ! git diff-files --quiet --ignore-submodules --
}

# Returns 0 if the working tree has untracked files.
has_untracked_files() {
  [ -n "$(git ls-files --others --exclude-standard)" ]
}

# Returns 0 if the working tree has stashed files.
has_stashed_files() {
  git rev-parse --verify refs/stash >/dev/null 2>&1
}

# Returns the name of the current branch.
git_branch_name() {
  git symbolic-ref --quiet --short HEAD 2> /dev/null || \
  git rev-parse --short HEAD 2> /dev/null || \
  echo "(unknown)"
}
