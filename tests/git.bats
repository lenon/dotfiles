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

@test "git::latest_tag on a clean repo" {
  init_git_repo
  run git::latest_tag

  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "git::latest_tag when a lightweight tag is the last one" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  git tag v0.0.1 -m "foo bar"
  git tag v0.0.2
  run git::latest_tag

  [ "$output" = "v0.0.2" ]
  [ "$status" -eq 0 ]
}

@test "git::latest_tag when an annotated tag is the last one" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  git tag v0.0.1
  git tag v0.0.2 -m "foo bar"
  run git::latest_tag

  [ "$output" = "v0.0.2" ]
  [ "$status" -eq 0 ]
}

@test "git::latest_tag when the chronological order is not respected" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  git tag v0.0.1
  git tag v0.0.3 -m "foo bar"
  git tag v0.0.4
  git tag v0.0.2
  run git::latest_tag

  [ "$output" = "v0.0.4" ]
  [ "$status" -eq 0 ]
}

@test "git::latest_tag with a custom prefix" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  git tag a0.0.1
  git tag b0.0.1
  git tag b0.0.2
  git tag c0.0.3
  run git::latest_tag "b"

  [ "$output" = "b0.0.2" ]
  [ "$status" -eq 0 ]
}

@test "git::latest_tag with the default prefix and no tags" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  git tag b0.0.1
  git tag b0.0.2
  run git::latest_tag

  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "git::latest_tag when a tag is not in version format" {
  init_git_repo
  touch a.txt
  git add a.txt
  git commit -m foo
  git tag v0.0.1
  git tag v0.0.2
  git tag vFoobar
  run git::latest_tag

  [ "$output" = "v0.0.2" ]
  [ "$status" -eq 0 ]
}
