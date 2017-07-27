#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${GOVENV_TEST_DIR}/myproject"
  cd "${GOVENV_TEST_DIR}/myproject"
}

@test "fails without arguments" {
  run govenv-version-file-read
  assert_failure ""
}

@test "fails for invalid file" {
  run govenv-version-file-read "non-existent"
  assert_failure ""
}

@test "fails for blank file" {
  echo > my-version
  run govenv-version-file-read my-version
  assert_failure ""
}

@test "reads simple version file" {
  cat > my-version <<<"3.3.5"
  run govenv-version-file-read my-version
  assert_success "3.3.5"
}

@test "ignores leading spaces" {
  cat > my-version <<<"  3.3.5"
  run govenv-version-file-read my-version
  assert_success "3.3.5"
}

@test "ignores leading blank lines" {
  cat > my-version <<IN

3.3.5
IN
  run govenv-version-file-read my-version
  assert_success "3.3.5"
}

@test "handles the file with no trailing newline" {
  echo -n "2.7.6" > my-version
  run govenv-version-file-read my-version
  assert_success "2.7.6"
}

@test "ignores carriage returns" {
  cat > my-version <<< $'3.3.5\r'
  run govenv-version-file-read my-version
  assert_success "3.3.5"
}
