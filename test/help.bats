#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run govenv-help
  assert_success
  assert_line "Usage: govenv <command> [<args>]"
  assert_line "Some useful govenv commands are:"
}

@test "invalid command" {
  run govenv-help hello
  assert_failure "govenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${GOVENV_TEST_DIR}/bin"
  cat > "${GOVENV_TEST_DIR}/bin/govenv-hello" <<SH
#!shebang
# Usage: govenv hello <world>
# Summary: Says "hello" to you, from govenv
# This command is useful for saying hello.
echo hello
SH

  run govenv-help hello
  assert_success
  assert_output <<SH
Usage: govenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${GOVENV_TEST_DIR}/bin"
  cat > "${GOVENV_TEST_DIR}/bin/govenv-hello" <<SH
#!shebang
# Usage: govenv hello <world>
# Summary: Says "hello" to you, from govenv
echo hello
SH

  run govenv-help hello
  assert_success
  assert_output <<SH
Usage: govenv hello <world>

Says "hello" to you, from govenv
SH
}

@test "extracts only usage" {
  mkdir -p "${GOVENV_TEST_DIR}/bin"
  cat > "${GOVENV_TEST_DIR}/bin/govenv-hello" <<SH
#!shebang
# Usage: govenv hello <world>
# Summary: Says "hello" to you, from govenv
# This extended help won't be shown.
echo hello
SH

  run govenv-help --usage hello
  assert_success "Usage: govenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${GOVENV_TEST_DIR}/bin"
  cat > "${GOVENV_TEST_DIR}/bin/govenv-hello" <<SH
#!shebang
# Usage: govenv hello <world>
#        govenv hi [everybody]
#        govenv hola --translate
# Summary: Says "hello" to you, from govenv
# Help text.
echo hello
SH

  run govenv-help hello
  assert_success
  assert_output <<SH
Usage: govenv hello <world>
       govenv hi [everybody]
       govenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${GOVENV_TEST_DIR}/bin"
  cat > "${GOVENV_TEST_DIR}/bin/govenv-hello" <<SH
#!shebang
# Usage: govenv hello <world>
# Summary: Says "hello" to you, from govenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run govenv-help hello
  assert_success
  assert_output <<SH
Usage: govenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
