#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${GOVENV_TEST_DIR}/myproject"
  cd "${GOVENV_TEST_DIR}/myproject"
  echo "1.2.3" > .go-version
  GOVENV_VERSION="" run govenv-sh-shell
  assert_failure "govenv: no shell-specific version configured"
}

@test "shell version" {
  GOVENV_SHELL=bash GOVENV_VERSION="1.2.3" run govenv-sh-shell
  assert_success 'echo "$GOVENV_VERSION"'
}

@test "shell version (fish)" {
  GOVENV_SHELL=fish GOVENV_VERSION="1.2.3" run govenv-sh-shell
  assert_success 'echo "$GOVENV_VERSION"'
}

@test "shell unset" {
  GOVENV_SHELL=bash run govenv-sh-shell --unset
  assert_success "unset GOVENV_VERSION"
}

@test "shell unset (fish)" {
  GOVENV_SHELL=fish run govenv-sh-shell --unset
  assert_success "set -e GOVENV_VERSION"
}

@test "shell change invalid version" {
  run govenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
govenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${GOVENV_ROOT}/versions/1.2.3"
  GOVENV_SHELL=bash run govenv-sh-shell 1.2.3
  assert_success 'export GOVENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${GOVENV_ROOT}/versions/1.2.3"
  GOVENV_SHELL=fish run govenv-sh-shell 1.2.3
  assert_success 'set -gx GOVENV_VERSION "1.2.3"'
}
