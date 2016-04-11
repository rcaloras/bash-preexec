#!/usr/bin/env bats

setup() {
  __bp_delay_install="true"
  source "${BATS_TEST_DIRNAME}/../bash-preexec.sh"
}

test_echo() {
  echo "test echo"
}

test_preexec_echo() {
  echo "$1"
}

@test "__bp_install_after_session_init should exit with 1 if we're not using bash" {
  unset BASH_VERSION
  run '__bp_install_after_session_init'
  [[ $status == 1 ]]
  [[ -z "$output" ]]
}

@test "__bp_install should exit if it's already installed" {
  PROMPT_COMMAND="some_other_function; __bp_precmd_invoke_cmd;"
  run '__bp_install'
  [[ $status == 1 ]]
  [[ -z "$output" ]]
}

@test "__bp_install should remove trap and itself from PROMPT_COMMAND" {
  trap_string="trap '__bp_preexec_invoke_exec' DEBUG;"
  PROMPT_COMMAND="some_other_function; $trap_string __bp_install;"

  [[ $PROMPT_COMMAND  == *"$trap_string"* ]]
  [[ $PROMPT_COMMAND  = *"__bp_install;"* ]]

  __bp_install

  [[ $PROMPT_COMMAND  != *"$trap_string"* ]]
  [[ $PROMPT_COMMAND  != *"__bp_install;"* ]]
  [[ -z "$output" ]]
}

@test "__bp_prompt_command_with_semi_colon should handle different PROMPT_COMMANDS" {
    # PROMPT_COMMAND of spaces
    PROMPT_COMMAND=" "

    run '__bp_prompt_command_with_semi_colon'
    [[ -z "$output" ]]

    # PROMPT_COMMAND of one command
    PROMPT_COMMAND="echo 'yo'"

    run '__bp_prompt_command_with_semi_colon'
    [[ "$output" == "echo 'yo';" ]]

    # No PROMPT_COMMAND
    unset PROMPT_COMMAND
    run '__bp_prompt_command_with_semi_colon'
    [[ -z "$output" ]]

    # PROMPT_COMMAND of two commands and trimmed
    PROMPT_COMMAND="echo 'yo'; ls    "

    run '__bp_prompt_command_with_semi_colon'
    [[ "$output" == "echo 'yo'; ls;" ]]
}


@test "No functions defined for preexec should simply return" {
    run '__bp_preexec_invoke_exec'
    [[ $status == 0 ]]
    [[ -z "$output" ]]
}

@test "precmd should execute a function once" {
    precmd_functions+=(test_echo)
    run '__bp_precmd_invoke_cmd'
    [[ $status == 0 ]]
    [[ "$output" == "test echo" ]]
}

@test "precmd should set $? to be the previous exit code" {
    echo_exit_code() {
      echo "$?"
      return 0
    }
    precmd_functions+=(echo_exit_code)

    __bp_set_ret_value() {
      return 251
    }

    run '__bp_precmd_invoke_cmd'
    [[ $status == 0 ]]
    [[ "$output" == "251" ]]
}


@test "preexec should execute a function with the last command in our history" {
    preexec_functions+=(test_preexec_echo)
    __bp_preexec_interactive_mode="on"
    git_command="git commit -a -m 'commiting some stuff'"
    history -s $git_command

    run '__bp_preexec_invoke_exec'
    [[ $status == 0 ]]
    [[ "$output" == "$git_command" ]]
}

@test "preexec should execute multiple functions in the order added to their arrays" {
    fun_1() { echo "$1 one"; }
    fun_2() { echo "$1 two"; }
    preexec_functions+=(fun_1)
    preexec_functions+=(fun_2)
    __bp_preexec_interactive_mode="on"
    history -s "fake command"

    run '__bp_preexec_invoke_exec'
    [[ $status == 0 ]]
    [[ "${lines[0]}" == "fake command one" ]]
    [[ "${lines[1]}" == "fake command two" ]]
}

@test "preecmd should execute multiple functions in the order added to their arrays" {
    fun_1() { echo "one"; }
    fun_2() { echo "two"; }
    precmd_functions+=(fun_1)
    precmd_functions+=(fun_2)

    run '__bp_precmd_invoke_cmd'
    [[ $status == 0 ]]
    [[ "${lines[0]}" == "one" ]]
    [[ "${lines[1]}" == "two" ]]
}

@test "in_prompt_command should detect if a command is part of PROMPT_COMMAND" {

    PROMPT_COMMAND="precmd_invoke_cmd; something;"
    run '__bp_in_prompt_command' "something"
    [[ $status == 0 ]]

    run '__bp_in_prompt_command' "something_else"
    [[ $status == 1 ]]

    # Should trim commands and arguments here.
    PROMPT_COMMAND=" precmd_invoke_cmd ; something ; some_stuff_here;"
    run '__bp_in_prompt_command' " precmd_invoke_cmd "
    [[ $status == 0 ]]

    PROMPT_COMMAND=" precmd_invoke_cmd ; something ; some_stuff_here;"
    run '__bp_in_prompt_command' " not_found"
    [[ $status == 1 ]]

}

@test "__bp_adjust_histcontrol should remove ignorespace and ignoreboth" {

    # Should remove ignorespace
    HISTCONTROL="ignorespace:ignoredups:*"
    __bp_adjust_histcontrol
    [[ "$HISTCONTROL" == ":ignoredups:*" ]]

    # Should remove ignoreboth and replace it with ignoredups
    HISTCONTROL="ignoreboth"
    __bp_adjust_histcontrol
    [[ "$HISTCONTROL" == "ignoredups:" ]]

    # Handle a few inputs
    HISTCONTROL="ignoreboth:ignorespace:some_thing_else"
    __bp_adjust_histcontrol
    echo "$HISTCONTROL"
    [[ "$HISTCONTROL" == "ignoredups:::some_thing_else" ]]

}

@test "preexec should respect HISTTIMEFORMAT" {
    preexec_functions+=(test_preexec_echo)
    __bp_preexec_interactive_mode="on"
    git_command="git commit -a -m 'commiting some stuff'"
    HISTTIMEFORMAT='%F %T '
    history -s $git_command

    run '__bp_preexec_invoke_exec'
    [[ $status == 0 ]]
    [[ "$output" == "$git_command" ]]
}
