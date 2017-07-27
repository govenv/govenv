#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run govenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${GOVENV_ROOT}/shims"
  touch "${GOVENV_ROOT}/shims/python"
  touch "${GOVENV_ROOT}/shims/irb"
  run govenv-shims
  assert_success
  assert_line "${GOVENV_ROOT}/shims/python"
  assert_line "${GOVENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${GOVENV_ROOT}/shims"
  touch "${GOVENV_ROOT}/shims/python"
  touch "${GOVENV_ROOT}/shims/irb"
  run govenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "python"
}
