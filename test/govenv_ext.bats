#!/usr/bin/env bats

load test_helper

@test "prefixes" {
  mkdir -p "${GOVENV_TEST_DIR}/bin"
  touch "${GOVENV_TEST_DIR}/bin/go"
  chmod +x "${GOVENV_TEST_DIR}/bin/go"
  mkdir -p "${GOVENV_ROOT}/versions/2.7.10"
  GOVENV_VERSION="system:2.7.10" run govenv-prefix
  assert_success "${GOVENV_TEST_DIR}:${GOVENV_ROOT}/versions/2.7.10"
  GOVENV_VERSION="2.7.10:system" run govenv-prefix
  assert_success "${GOVENV_ROOT}/versions/2.7.10:${GOVENV_TEST_DIR}"
}

@test "should use dirname of file argument as GOVENV_DIR" {
  mkdir -p "${GOVENV_TEST_DIR}/dir1"
  touch "${GOVENV_TEST_DIR}/dir1/file.py"
  GOVENV_FILE_ARG="${GOVENV_TEST_DIR}/dir1/file.py" run govenv echo GOVENV_DIR
  assert_output "${GOVENV_TEST_DIR}/dir1"
}

@test "should follow symlink of file argument (#379, #404)" {
  mkdir -p "${GOVENV_TEST_DIR}/dir1"
  mkdir -p "${GOVENV_TEST_DIR}/dir2"
  touch "${GOVENV_TEST_DIR}/dir1/file.py"
  ln -s "${GOVENV_TEST_DIR}/dir1/file.py" "${GOVENV_TEST_DIR}/dir2/symlink.py"
  GOVENV_FILE_ARG="${GOVENV_TEST_DIR}/dir2/symlink.py" run govenv echo GOVENV_DIR
  assert_output "${GOVENV_TEST_DIR}/dir1"
}
