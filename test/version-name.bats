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
  run govenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  GOVENV_VERSION=system run govenv-version-name
  assert_success "system"
}

@test "GOVENV_VERSION can be overridden by hook" {
  create_version "2.7.11"
  create_version "3.5.1"
  create_hook version-name test.bash <<<"GOVENV_VERSION=3.5.1"

  GOVENV_VERSION=2.7.11 run govenv-version-name
  assert_success "3.5.1"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export GOVENV_VERSION=system
  IFS=$' \t\n' run govenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "GOVENV_VERSION has precedence over local" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > ".go-version" <<<"2.7.11"
  run govenv-version-name
  assert_success "2.7.11"

  GOVENV_VERSION=3.5.1 run govenv-version-name
  assert_success "3.5.1"
}

@test "local file has precedence over global" {
  create_version "2.7.11"
  create_version "3.5.1"

  cat > "${GOVENV_ROOT}/version" <<<"2.7.11"
  run govenv-version-name
  assert_success "2.7.11"

  cat > ".go-version" <<<"3.5.1"
  run govenv-version-name
  assert_success "3.5.1"
}

@test "missing version" {
  GOVENV_VERSION=1.2 run govenv-version-name
  assert_failure "govenv: version \`1.2' is not installed (set by GOVENV_VERSION environment variable)"
}

@test "one missing version (second missing)" {
  create_version "3.5.1"
  GOVENV_VERSION="3.5.1:1.2" run govenv-version-name
  assert_failure
  assert_output <<OUT
govenv: version \`1.2' is not installed (set by GOVENV_VERSION environment variable)
3.5.1
OUT
}

@test "one missing version (first missing)" {
  create_version "3.5.1"
  GOVENV_VERSION="1.2:3.5.1" run govenv-version-name
  assert_failure
  assert_output <<OUT
govenv: version \`1.2' is not installed (set by GOVENV_VERSION environment variable)
3.5.1
OUT
}

govenv-version-name-without-stderr() {
  govenv-version-name 2>/dev/null
}

@test "one missing version (without stderr)" {
  create_version "3.5.1"
  GOVENV_VERSION="1.2:3.5.1" run govenv-version-name-without-stderr
  assert_failure
  assert_output <<OUT
3.5.1
OUT
}

@test "version with prefix in name" {
  create_version "2.7.11"
  cat > ".go-version" <<<"go-2.7.11"
  run govenv-version-name
  assert_success
  assert_output "2.7.11"
}
