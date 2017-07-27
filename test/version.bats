#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${GOVENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$GOVENV_TEST_DIR"
  cd "$GOVENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${GOVENV_ROOT}/versions" ]
  run govenv-version
  assert_success "system (set by ${GOVENV_ROOT}/version)"
}

@test "set by GOVENV_VERSION" {
  create_version "3.3.3"
  GOVENV_VERSION=3.3.3 run govenv-version
  assert_success "3.3.3 (set by GOVENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "3.3.3"
  cat > ".go-version" <<<"3.3.3"
  run govenv-version
  assert_success "3.3.3 (set by ${PWD}/.go-version)"
}

@test "set by global file" {
  create_version "3.3.3"
  cat > "${GOVENV_ROOT}/version" <<<"3.3.3"
  run govenv-version
  assert_success "3.3.3 (set by ${GOVENV_ROOT}/version)"
}

@test "set by GOVENV_VERSION, one missing" {
  create_version "3.3.3"
  GOVENV_VERSION=3.3.3:1.2 run govenv-version
  assert_failure
  assert_output <<OUT
govenv: version \`1.2' is not installed (set by GOVENV_VERSION environment variable)
3.3.3 (set by GOVENV_VERSION environment variable)
OUT
}

@test "set by GOVENV_VERSION, two missing" {
  create_version "3.3.3"
  GOVENV_VERSION=3.4.2:3.3.3:1.2 run govenv-version
  assert_failure
  assert_output <<OUT
govenv: version \`3.4.2' is not installed (set by GOVENV_VERSION environment variable)
govenv: version \`1.2' is not installed (set by GOVENV_VERSION environment variable)
3.3.3 (set by GOVENV_VERSION environment variable)
OUT
}

govenv-version-without-stderr() {
  govenv-version 2>/dev/null
}

@test "set by GOVENV_VERSION, one missing (stderr filtered)" {
  create_version "3.3.3"
  GOVENV_VERSION=3.4.2:3.3.3 run govenv-version-without-stderr
  assert_failure
  assert_output <<OUT
3.3.3 (set by GOVENV_VERSION environment variable)
OUT
}
