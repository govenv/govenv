#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${GOVENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "2.7" "python"
  create_executable "3.4" "py.test"

  GOVENV_VERSION=2.7 run govenv-which python
  assert_success "${GOVENV_ROOT}/versions/2.7/bin/python"

  GOVENV_VERSION=3.4 run govenv-which py.test
  assert_success "${GOVENV_ROOT}/versions/3.4/bin/py.test"

  GOVENV_VERSION=3.4:2.7 run govenv-which py.test
  assert_success "${GOVENV_ROOT}/versions/3.4/bin/py.test"
}

@test "searches PATH for system version" {
  create_executable "${GOVENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${GOVENV_ROOT}/shims" "kill-all-humans"

  GOVENV_VERSION=system run govenv-which kill-all-humans
  assert_success "${GOVENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${GOVENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${GOVENV_ROOT}/shims" "kill-all-humans"

  PATH="${GOVENV_ROOT}/shims:$PATH" GOVENV_VERSION=system run govenv-which kill-all-humans
  assert_success "${GOVENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${GOVENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${GOVENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${GOVENV_ROOT}/shims" GOVENV_VERSION=system run govenv-which kill-all-humans
  assert_success "${GOVENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${GOVENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${GOVENV_ROOT}/shims" "kill-all-humans"

  PATH="${GOVENV_ROOT}/shims:${GOVENV_ROOT}/shims:/tmp/non-existent:$PATH:${GOVENV_ROOT}/shims" \
    GOVENV_VERSION=system run govenv-which kill-all-humans
  assert_success "${GOVENV_TEST_DIR}/bin/kill-all-humans"
}

@test "doesn't include current directory in PATH search" {
  export PATH="$(path_without "kill-all-humans")"
  mkdir -p "$GOVENV_TEST_DIR"
  cd "$GOVENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  GOVENV_VERSION=system run govenv-which kill-all-humans
  assert_failure "govenv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "3.4" "py.test"
  GOVENV_VERSION=3.3 run govenv-which py.test
  assert_failure "govenv: version \`3.3' is not installed (set by GOVENV_VERSION environment variable)"
}

@test "versions not installed" {
  create_executable "3.4" "py.test"
  GOVENV_VERSION=2.7:3.3 run govenv-which py.test
  assert_failure <<OUT
govenv: version \`2.7' is not installed (set by GOVENV_VERSION environment variable)
govenv: version \`3.3' is not installed (set by GOVENV_VERSION environment variable)
OUT
}

@test "no executable found" {
  create_executable "2.7" "py.test"
  GOVENV_VERSION=2.7 run govenv-which fab
  assert_failure "govenv: fab: command not found"
}

@test "no executable found for system version" {
  export PATH="$(path_without "py.test")"
  GOVENV_VERSION=system run govenv-which py.test
  assert_failure "govenv: py.test: command not found"
}

@test "executable found in other versions" {
  create_executable "2.7" "python"
  create_executable "3.3" "py.test"
  create_executable "3.4" "py.test"

  GOVENV_VERSION=2.7 run govenv-which py.test
  assert_failure
  assert_output <<OUT
govenv: py.test: command not found

The \`py.test' command exists in these Go versions:
  3.3
  3.4
OUT
}

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' GOVENV_VERSION=system run govenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from govenv-version-name" {
  mkdir -p "$GOVENV_ROOT"
  cat > "${GOVENV_ROOT}/version" <<<"1.6.1"
  create_executable "1.6.1" "go"

  mkdir -p "$GOVENV_TEST_DIR"
  cd "$GOVENV_TEST_DIR"

  GOVENV_VERSION= run govenv-which go
  assert_success "${GOVENV_ROOT}/versions/1.6.1/bin/go"
}
