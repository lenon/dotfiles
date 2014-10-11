#!/usr/bin/env bats
load test_helper

init_git_repo() {
  mkdir gitrepo
  cd gitrepo
  git init > /dev/null 2>&1
}

@test "git::repo? outside a Git repo" {
  run git::repo?

  [ "$output" = "" ]
  [ "$status" -eq 128 ]
}

@test "git::repo? inside a Git repo" {
  init_git_repo

  run git::repo?

  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "git::dot_dir? on the root of a Git repo" {
  init_git_repo

  run git::dot_dir?

  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "git::dot_dir? on the root of a Git repo" {
  init_git_repo
  cd .git

  run git::dot_dir?

  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "git::uncommitted_changes? on a clean working tree" {
  init_git_repo

  run git::uncommitted_changes?

  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "git::uncommitted_changes? on a clean staging" {
  init_git_repo
  touch a.txt

  run git::uncommitted_changes?

  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "git::uncommitted_changes? when some change is on staging" {
  init_git_repo
  touch a.txt
  git add a.txt

  run git::uncommitted_changes?

  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "git::unstaged_files? on a clean working tree" {
  init_git_repo

  run git::unstaged_files?

  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "git::unstaged_files? when some change is not staged" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  echo bar > a.txt

  run git::unstaged_files?

  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "git::untracked_files? on a clean working tree" {
  init_git_repo

  run git::untracked_files?

  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "git::untracked_files? when a file is not tracked by Git" {
  init_git_repo
  touch a.txt

  run git::untracked_files?

  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "git::stashed_files? on a clean working tree" {
  init_git_repo

  run git::stashed_files?

  [ "$output" = "" ]
  [ "$status" -eq 128 ]
}

@test "git::stashed_files? on a clean working tree" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  echo foo > a.txt
  git stash

  run git::stashed_files?

  [ "$output" = "" ]
  [ "$status" -eq 0 ]
}

@test "git::branch_name on master" {
  init_git_repo

  run git::branch_name

  [ "$output" = "master" ]
  [ "$status" -eq 0 ]
}

@test "git::branch_name on other branch" {
  init_git_repo
  git checkout -b foo

  run git::branch_name

  [ "$output" = "foo" ]
  [ "$status" -eq 0 ]
}

@test "git::branch_name on detached HEAD" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  local commit=$(git rev-parse --short HEAD)
  git checkout "${commit}"

  run git::branch_name

  [ "$output" = "${commit}" ]
  [ "$status" -eq 0 ]
}
