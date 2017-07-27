#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run govenv-hooks
  assert_failure "Usage: govenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${GOVENV_TEST_DIR}/govenv.d"
  path2="${GOVENV_TEST_DIR}/etc/govenv_hooks"
  GOVENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  GOVENV_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

  GOVENV_HOOK_PATH="$path1:$path2" run govenv-hooks exec
  assert_success
  assert_output <<OUT
${GOVENV_TEST_DIR}/govenv.d/exec/ahoy.bash
${GOVENV_TEST_DIR}/govenv.d/exec/hello.bash
${GOVENV_TEST_DIR}/etc/govenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${GOVENV_TEST_DIR}/my hooks/govenv.d"
  path2="${GOVENV_TEST_DIR}/etc/govenv hooks"
  GOVENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  GOVENV_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  GOVENV_HOOK_PATH="$path1:$path2" run govenv-hooks exec
  assert_success
  assert_output <<OUT
${GOVENV_TEST_DIR}/my hooks/govenv.d/exec/hello.bash
${GOVENV_TEST_DIR}/etc/govenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  GOVENV_HOOK_PATH="${GOVENV_TEST_DIR}/govenv.d"
  create_hook exec "hello.bash"
  mkdir -p "$HOME"

  GOVENV_HOOK_PATH="${HOME}/../govenv.d" run govenv-hooks exec
  assert_success "${GOVENV_TEST_DIR}/govenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${GOVENV_TEST_DIR}/govenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  GOVENV_HOOK_PATH="$path" run govenv-hooks exec
  assert_success
  assert_output <<OUT
${HOME}/hola.bash
${GOVENV_TEST_DIR}/govenv.d/exec/bright.sh
OUT
}
