#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${GOVENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${GOVENV_ROOT}/shims" ]
  run govenv-rehash
  assert_success ""
  assert [ -d "${GOVENV_ROOT}/shims" ]
  rmdir "${GOVENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${GOVENV_ROOT}/shims"
  chmod -w "${GOVENV_ROOT}/shims"
  run govenv-rehash
  assert_failure "govenv: cannot rehash: ${GOVENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${GOVENV_ROOT}/shims"
  touch "${GOVENV_ROOT}/shims/.govenv-shim"
  run govenv-rehash
  assert_failure "govenv: cannot rehash: ${GOVENV_ROOT}/shims/.govenv-shim exists"
}

@test "creates shims" {
  create_executable "2.7" "go"
  create_executable "3.4" "go"

  assert [ ! -e "${GOVENV_ROOT}/shims/go" ]

  run govenv-rehash
  assert_success ""

  run ls "${GOVENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
go
OUT
}

@test "removes stale shims" {
  mkdir -p "${GOVENV_ROOT}/shims"
  touch "${GOVENV_ROOT}/shims/oldshim1"
  chmod +x "${GOVENV_ROOT}/shims/oldshim1"

  create_executable "3.4" "go"

  run govenv-rehash
  assert_success ""

  assert [ ! -e "${GOVENV_ROOT}/shims/oldshim1" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "go"

  assert [ ! -e "${GOVENV_ROOT}/shims/go" ]

  run govenv-rehash
  assert_success ""

  run ls "${GOVENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
go
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run govenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "3.4" "go"
  GOVENV_SHELL=bash run govenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${GOVENV_ROOT}/shims/go" ]
}

@test "sh-rehash in fish" {
  create_executable "3.4" "go"
  GOVENV_SHELL=fish run govenv-sh-rehash
  assert_success ""
  assert [ -x "${GOVENV_ROOT}/shims/go" ]
}
