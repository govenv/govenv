#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$GOVENV_TEST_DIR"
  cd "$GOVENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run govenv-version-file-write
  assert_failure "Usage: govenv version-file-write <file> <version>"
  run govenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".go-version" ]
  run govenv-version-file-write ".go-version" "2.7.6"
  assert_failure "govenv: version \`2.7.6' not installed"
  assert [ ! -e ".go-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${GOVENV_ROOT}/versions/2.7.6"
  assert [ ! -e "my-version" ]
  run govenv-version-file-write "${PWD}/my-version" "2.7.6"
  assert_success ""
  assert [ "$(cat my-version)" = "2.7.6" ]
}
