#!/usr/bin/env bats

load test_helper

@test "default" {
  run govenv-global
  assert_success
  assert_output "system"
}

@test "read GOVENV_ROOT/version" {
  mkdir -p "$GOVENV_ROOT"
  echo "1.2.3" > "$GOVENV_ROOT/version"
  run govenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set GOVENV_ROOT/version" {
  mkdir -p "$GOVENV_ROOT/versions/1.2.3"
  run govenv-global "1.2.3"
  assert_success
  run govenv-global
  assert_success "1.2.3"
}

@test "fail setting invalid GOVENV_ROOT/version" {
  mkdir -p "$GOVENV_ROOT"
  run govenv-global "1.2.3"
  assert_failure "govenv: version \`1.2.3' not installed"
}
