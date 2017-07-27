#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${GOVENV_TEST_DIR}/myproject"
  cd "${GOVENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.go-version" ]
  run govenv-local
  assert_failure "govenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .go-version
  run govenv-local
  assert_success "1.2.3"
}

@test "discovers version file in parent directory" {
  echo "1.2.3" > .go-version
  mkdir -p "subdir" && cd "subdir"
  run govenv-local
  assert_success "1.2.3"
}

@test "ignores GOVENV_DIR" {
  echo "1.2.3" > .go-version
  mkdir -p "$HOME"
  echo "3.4-home" > "${HOME}/.go-version"
  GOVENV_DIR="$HOME" run govenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${GOVENV_ROOT}/versions/1.2.3"
  run govenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .go-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .go-version
  mkdir -p "${GOVENV_ROOT}/versions/1.2.3"
  run govenv-local
  assert_success "1.0-pre"
  run govenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .go-version)" = "1.2.3" ]
}

@test "unsets local version" {
  touch .go-version
  run govenv-local --unset
  assert_success ""
  assert [ ! -e .go-version ]
}
