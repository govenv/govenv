#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$GOVENV_TEST_DIR"
  cd "$GOVENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "detects global 'version' file" {
  create_file "${GOVENV_ROOT}/version"
  run govenv-version-file
  assert_success "${GOVENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${GOVENV_ROOT}/version" ]
  assert [ ! -e ".go-version" ]
  run govenv-version-file
  assert_success "${GOVENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".go-version"
  run govenv-version-file
  assert_success "${GOVENV_TEST_DIR}/.go-version"
}

@test "in parent directory" {
  create_file ".go-version"
  mkdir -p project
  cd project
  run govenv-version-file
  assert_success "${GOVENV_TEST_DIR}/.go-version"
}

@test "topmost file has precedence" {
  create_file ".go-version"
  create_file "project/.go-version"
  cd project
  run govenv-version-file
  assert_success "${GOVENV_TEST_DIR}/project/.go-version"
}

@test "GOVENV_DIR has precedence over PWD" {
  create_file "widget/.go-version"
  create_file "project/.go-version"
  cd project
  GOVENV_DIR="${GOVENV_TEST_DIR}/widget" run govenv-version-file
  assert_success "${GOVENV_TEST_DIR}/widget/.go-version"
}

@test "PWD is searched if GOVENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.go-version"
  cd project
  GOVENV_DIR="${GOVENV_TEST_DIR}/widget/blank" run govenv-version-file
  assert_success "${GOVENV_TEST_DIR}/project/.go-version"
}

@test "finds version file in target directory" {
  create_file "project/.go-version"
  run govenv-version-file "${PWD}/project"
  assert_success "${GOVENV_TEST_DIR}/project/.go-version"
}

@test "fails when no version file in target directory" {
  run govenv-version-file "$PWD"
  assert_failure ""
}
