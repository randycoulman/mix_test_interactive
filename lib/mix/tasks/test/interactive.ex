defmodule Mix.Tasks.Test.Interactive do
  @shortdoc "Interactively run tests"
  @moduledoc """
  Interactive test runner for ExUnit tests.

  `mix test.interactive` allows you to easily switch between running all tests,
  stale tests, or failed tests. Or, you can run only the tests whose filenames
  contain a substring. You can also control which tags are included or excluded,
  modify the maximum number of failures allowed, repeat the test suite until a
  failure occurs, specify the test seed to use, and toggle tracing on and off.
  Includes an optional "watch mode" which runs tests after every file change.

  ## Usage

  ```shell
  mix test.interactive <options> [-- <mix test arguments>]
  mix test.interactive <mix test arguments>
  mix test.interactive --help
  mix test.interactive --version
  ```

  Your tests will run immediately (and every time a file changes).

  ### Options

  `mix test.interactive` understands the following options, most of which
  correspond to configuration settings below.

  Note that, if you want to pass both mix test.interactive options and mix test
  arguments, you must separate them with `--`.

  If an option is provided on the command line, it will override the same option
  specified in the configuration.

  - `--(no-)clear`: Clear the console before each run (default `false`).
  - `--command <command> [--arg <arg>]`: Custom command and arguments for
    running tests (default: "mix" with no arguments). NOTE: Use `--arg` multiple
    times to specify more than one argument.
  - `--exclude <regex>`: Exclude files/directories from triggering test runs
    (default: `["~r/\.#/", "~r{priv/repo/migrations}"`]) NOTE: Use `--exclude`
    multiple times to specify more than one regex.
  - `--extra-extensions <extension>`: Watch files with additional extensions
    (default: []).
  - `--runner <module name>`: Use a custom runner module (default:
    `MixTestInteractive.PortRunner`).
  - `--task <task name>`: Run a different mix task (default: `"test"`).
  - `--(no-)timestamp`: Display the current time before running the tests
    (default: `false`).
  - `--(no-)watch`: Don't run tests when a file changes (default: `true`).

  All of the `<mix test arguments>` are passed through to `mix test` on every
  test run.

  `mix test.interactive` will detect the `--exclude`, `--failed`, `--include`,
  `--only`, `--seed`, and `--stale` options and use those as initial settings in
  interactive mode. You can then use the interactive mode commands to adjust
  those options as needed. It will also detect any filename or pattern arguments
  and use those as initial settings. Note that if you specify a pattern on the
  command-line, `mix test.interactive` will find all test files matching that
  pattern and pass those to `mix test` as if you had used the `p` command.

  ### Patterns and filenames

  `mix test.interactive` can take the same filename or filename:line_number
  patterns that `mix test` understands. It also allows you to specify one or
  more "patterns" - strings that match one or more test files. When you provide
  one or more patterns on the command-line, `mix test.interactive` will find all
  test files matching those patterns and pass them to `mix test` as if you had
  used the `p` command (described below).

  ## Interactive Commands

  After the tests run, you can use the interactive commands to change which
  tests will run.

  - `a`: Run all tests. Clears the `--failed` and `--stale` options as well as
    any patterns.
  - `d <seed>`: Run the tests with a specific seed.
  - `d`: Clear any previously specified seed.
  - `f`: Run only tests that failed on the last run (equivalent to the
  `--failed` option of `mix test`).
  - `i <tags...>`: Include tests tagged with the listed tags (equivalent to the
    `--include` option of `mix test`).
  - `i`: Clear any included tags.
  - `m <max>`: Specify the maximum number of failures allowed (equivalent to the
    `--max-failures` option of `mix test`).
  - `m`: Clear any previously specified maximum number of failures.
  - `o <tags...>`: Run only tests tagged with the listed tags (equivalent to the
    `--only` option of `mix test`).
  - `o`: Clear any "only" tags.
  - `p`: Run only test files that match one or more provided patterns. A pattern
    is the project-root-relative path to a test file (with or without a line
    number specification) or a string that matches a portion of full pathname.
    e.g. `test/my_project/my_test.exs`, `test/my_project/my_test.exs:12:24` or
    `my`.
  - `q`: Exit the program. (Can also use `Ctrl-D`.)
  - `r <count>`: (Elixir 1.17.0 and later) Run tests up to <count> times until a
    failure occurs (equivalent to the `--repeat-until-failure` option of `mix
    test`).
  - `r`: (Elixir 1.17.0 and later) Clear the "repeat-until-failure" count.
  - `s`: Run only test files that reference modules that have changed since the
    last run (equivalent to the `--stale` option of `mix test`).
  - `t`: Turn test tracing on or off (equivalent to the `--trace` option of `mix
    test).
  - `x <tags...>`: Exclude tests tagged with the listed tags (equivalent to the
    `--exclude` option of `mix test`).
  - `x`: Clear any excluded tags.
  - `w`: Turn file-watching mode on or off.
  - `Enter`: Re-run the current set of tests without requiring a file change.
  - `?`: Show usage help.

  ## Configuration

  If your project has a `config/config.exs` file, you can customize the
  operation of `mix test.interactive` with the following settings:

  - `clear: true`: Clear the console before each run (default: `false`).
  - `command: <program>` or `command: {<program>, [<arg>, ...]}`: Use the
    provided command and arguments to run the test task (default: `mix`).
  - `exclude: [patterns...]`: A list of `Regex`es to ignore when watching for
    changes (default: `[~r/\.#/, ~r{priv/repo/migrations}]`).
  - `extra_extensions: [<ext>...]`: Additional filename extensions to include
    when watching for file changes (default: `[]`).
  - `runner: <module>`: A custom runner for running the tests (default:
    `MixTestInteractive.PortRunner`).
  - `task: <task name>`: The mix task to use when running tests (default:
    `"test"`).
  - `timestamp: true`: Print current time (UTC) before running tests (default:
    false).
  """

  use Mix.Task

  @preferred_cli_env :test
  @requirements ["app.config"]

  defdelegate run(args), to: MixTestInteractive
end
