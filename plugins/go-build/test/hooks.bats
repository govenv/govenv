#!/usr/bin/env bats

load test_helper

setup() {
  export GOVENV_ROOT="${TMP}/govenv"
  export HOOK_PATH="${TMP}/i has hooks"
  mkdir -p "$HOOK_PATH"
}

@test "govenv-install hooks" {
  cat > "${HOOK_PATH}/install.bash" <<OUT
before_install 'echo before: \$PREFIX'
after_install 'echo after: \$STATUS'
OUT
  stub govenv-hooks "install : echo '$HOOK_PATH'/install.bash"
  stub govenv-rehash "echo rehashed"

  definition="${TMP}/3.2.1"
  cat > "$definition" <<<"echo go-build"
  run govenv-install "$definition"

  assert_success
  assert_output <<-OUT
before: ${GOVENV_ROOT}/versions/3.2.1
go-build
after: 0
rehashed
OUT
}

@test "govenv-uninstall hooks" {
  cat > "${HOOK_PATH}/uninstall.bash" <<OUT
before_uninstall 'echo before: \$PREFIX'
after_uninstall 'echo after.'
rm() {
  echo "rm \$@"
  command rm "\$@"
}
OUT
  stub govenv-hooks "uninstall : echo '$HOOK_PATH'/uninstall.bash"
  stub govenv-rehash "echo rehashed"

  mkdir -p "${GOVENV_ROOT}/versions/3.2.1"
  run govenv-uninstall -f 3.2.1

  assert_success
  assert_output <<-OUT
before: ${GOVENV_ROOT}/versions/3.2.1
rm -rf ${GOVENV_ROOT}/versions/3.2.1
rehashed
after.
OUT

  refute [ -d "${GOVENV_ROOT}/versions/3.2.1" ]
}
