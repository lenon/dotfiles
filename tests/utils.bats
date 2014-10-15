#!/usr/bin/env bats
load test_helper

@test "semver::parse with an invalid version" {
  run semver::parse "invalid"
  [ "$output" = "" ]
  [ "$status" -eq 1 ]

  run semver::parse "1_0_0"
  [ "$output" = "" ]
  [ "$status" -eq 1 ]

  run semver::parse "v1_0_0"
  [ "$output" = "" ]
  [ "$status" -eq 1 ]

  run semver::parse "1.0.0"
  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "semver::parse with a valid version" {
  run semver::parse "v1.0.0"
  [ "$output" = "v 1 0 0" ]
  [ "$status" -eq 0 ]

  run semver::parse "v_1.0.0"
  [ "$output" = "v_ 1 0 0" ]
  [ "$status" -eq 0 ]
}

@test "semver::increment_patch with an invalid version" {
  run semver::increment_patch "invalid"

  [ "$output" = "" ]
  [ "$status" -eq 1 ]
}

@test "semver::increment_patch with a valid version" {
  run semver::increment_patch "v1.0.0"

  [ "$output" = "v1.0.1" ]
  [ "$status" -eq 0 ]
}

@test "semver::increment_patch with a custom increment number" {
  run semver::increment_patch "v1.0.0" 2

  [ "$output" = "v1.0.2" ]
  [ "$status" -eq 0 ]
}
