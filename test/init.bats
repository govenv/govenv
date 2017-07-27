#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${GOVENV_ROOT}/shims" ]
  assert [ ! -d "${GOVENV_ROOT}/versions" ]
  run govenv-init -
  assert_success
  assert [ -d "${GOVENV_ROOT}/shims" ]
  assert [ -d "${GOVENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run govenv-init -
  assert_success
  assert_line "command govenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run govenv-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/govenv.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run govenv-init -
  assert_success
  assert_line "export GOVENV_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$GOVENV_TEST_DIR"
  cd "$GOVENV_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(govenv-init -)"
echo \$GOVENV_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh /bin/zsh
  assert_success "sh"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run govenv-init - fish
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/govenv.fish'"
}

@test "fish instructions" {
  run govenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and . (govenv init -|psub)'
}

@test "option to skip rehash" {
  run govenv-init - --no-rehash
  assert_success
  refute_line "govenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run govenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${GOVENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run govenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${GOVENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${GOVENV_ROOT}/shims:$PATH"
  run govenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${GOVENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${GOVENV_ROOT}/shims:$PATH"
  run govenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${GOVENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run govenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run govenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run govenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
