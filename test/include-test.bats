#!/usr/bin/env bats

# This variable tells bash-preexec.sh that it is loaded for testing purposes.
# bash-preexec.sh is intended to be used in interactive shell sessions, so it
# is disabled in non-interactive shells by default.  However, it still needs to
# be loaded in non-interactive shells for the Bats tests.
__bp_inside_test=yes

@test "should not import if it's already defined" {
  bash_preexec_imported="defined"
  source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
  [ -z $(type -t __bp_install) ]
}

@test "should not import if it's already defined (old guard, don't use elsewhere!)" {
  __bp_imported="defined"
  source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
  [ -z $(type -t __bp_install) ]
}

@test "should import if not defined" {
  unset bash_preexec_imported
  source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
  [ -n $(type -t __bp_install) ]
}

@test "bp should stop installation if HISTTIMEFORMAT is readonly" {
  readonly HISTTIMEFORMAT
  run source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
  [ $status -ne 0 ]
  [[ "$output" =~ "HISTTIMEFORMAT" ]] || return 1
}
