#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$GOVENV_TEST_DIR"
  cd "$GOVENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${GOVENV_ROOT}/version" ]
  run govenv-version-origin
  assert_success "${GOVENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$GOVENV_ROOT"
  touch "${GOVENV_ROOT}/version"
  run govenv-version-origin
  assert_success "${GOVENV_ROOT}/version"
}

@test "detects GOVENV_VERSION" {
  GOVENV_VERSION=1 run govenv-version-origin
  assert_success "GOVENV_VERSION environment variable"
}

@test "detects local file" {
  touch .go-version
  run govenv-version-origin
  assert_success "${PWD}/.go-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"GOVENV_VERSION_ORIGIN=plugin"

  GOVENV_VERSION=1 run govenv-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export GOVENV_VERSION=system
  IFS=$' \t\n' run govenv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit GOVENV_VERSION_ORIGIN from environment" {
  GOVENV_VERSION_ORIGIN=ignored run govenv-version-origin
  assert_success "${GOVENV_ROOT}/version"
}
