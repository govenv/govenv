#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run govenv
  assert_failure
  assert_line 0 "$(govenv---version)"
}

@test "invalid command" {
  run govenv does-not-exist
  assert_failure
  assert_output "govenv: no such command \`does-not-exist'"
}

@test "default GOVENV_ROOT" {
  GOVENV_ROOT="" HOME=/home/mislav run govenv root
  assert_success
  assert_output "/home/mislav/.govenv"
}

@test "inherited GOVENV_ROOT" {
  GOVENV_ROOT=/opt/govenv run govenv root
  assert_success
  assert_output "/opt/govenv"
}

@test "default GOVENV_DIR" {
  run govenv echo GOVENV_DIR
  assert_output "$(pwd)"
}

@test "inherited GOVENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  GOVENV_DIR="$dir" run govenv echo GOVENV_DIR
  assert_output "$dir"
}

@test "invalid GOVENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  GOVENV_DIR="$dir" run govenv echo GOVENV_DIR
  assert_failure
  assert_output "govenv: cannot change working directory to \`$dir'"
}

@test "adds its own libexec to PATH" {
  run govenv echo "PATH"
  assert_success "${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$GOVENV_ROOT"/plugins/go-build/bin
  mkdir -p "$GOVENV_ROOT"/plugins/govenv-each/bin
  run govenv echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${GOVENV_ROOT}/plugins/go-build/bin"
  assert_line 2 "${GOVENV_ROOT}/plugins/govenv-each/bin"
}

@test "GOVENV_HOOK_PATH preserves value from environment" {
  GOVENV_HOOK_PATH=/my/hook/path:/other/hooks run govenv echo -F: "GOVENV_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${GOVENV_ROOT}/govenv.d"
}

@test "GOVENV_HOOK_PATH includes govenv built-in plugins" {
  unset GOVENV_HOOK_PATH
  run govenv echo "GOVENV_HOOK_PATH"
  assert_success "${GOVENV_ROOT}/govenv.d:${BATS_TEST_DIRNAME%/*}/govenv.d:/usr/local/etc/govenv.d:/etc/govenv.d:/usr/lib/govenv/hooks"
}
