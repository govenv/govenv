#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${GOVENV_TEST_DIR}/myproject"
  cd "${GOVENV_TEST_DIR}/myproject"
  echo "1.2.3" > .go-version
  mkdir -p "${GOVENV_ROOT}/versions/1.2.3"
  run govenv-prefix
  assert_success "${GOVENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  GOVENV_VERSION="1.2.3" run govenv-prefix
  assert_failure "govenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${GOVENV_TEST_DIR}/bin"
  touch "${GOVENV_TEST_DIR}/bin/go"
  chmod +x "${GOVENV_TEST_DIR}/bin/go"
  GOVENV_VERSION="system" run govenv-prefix
  assert_success "$GOVENV_TEST_DIR"
}

@test "prefix for invalid system" {
  PATH="$(path_without go)" run govenv-prefix system
  assert_failure "govenv: system version not found in PATH"
}
