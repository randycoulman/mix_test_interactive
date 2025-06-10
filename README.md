# mix test.interactive

[![Build
Status](https://github.com/randycoulman/mix_test_interactive/actions/workflows/ci.yml/badge.svg)](https://github.com/randycoulman/mix_test_interactive/actions)
[![Module
Version](https://img.shields.io/hexpm/v/mix_test_interactive.svg)](https://hex.pm/packages/mix_test_interactive)
[![Hex
Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/mix_test_interactive/)
[![License](https://img.shields.io/hexpm/l/mix_test_interactive.svg)](https://github.com/randycoulman/mix_test_interactive/blob/master/LICENSE.md)

`mix test.interactive` is an interactive test runner for ExUnit tests.

Based on Louis Pilfold's wonderful
[mix-test.watch](https://github.com/lpil/mix-test.watch) and inspired by Jest's
interactive watch mode, `mix test.interactive` allows you to dynamically change
which tests should be run with a few keystrokes.

It allows you to easily switch between running all tests, stale tests, or failed
tests. Or, you can run only the tests whose filenames contain a substring. You
can also control which tags are included or excluded, modify the maximum number
of failures allowed, repeat the test suite until a failure occurs, specify the
test seed to use, and toggle tracing on and off. Includes an optional "watch
mode" which runs tests after every file change.

## Installation

`mix test.interactive` can be added as a dependency to your project, or it can
be run from an Elixir script without being added to your project.

### Installing as a Dependency

To install `mix test.interactive` as a dependency of your project, making it
available to anyone working in the project, add `mix_test_interactive` to the
list of dependencies in your project's `mix.exs` file:

```elixir
def deps do
  [
    {:mix_test_interactive, "~> 5.0", only: :dev, runtime: false}
  ]
end
```

### Running from an Elixir Script

If you are working on a 3rd-party project, you may not be able to add
`mix test.interactive` as a dependency. In this case, it is possible
to invoke `mix test.interactive` from an Elixir script.

To accomplish this, put the following script somewhere on your PATH and make it
executable.

```elixir
#!/usr/bin/env elixir

Mix.install([
  {:mix_test_interactive, "~> 4.1"}
])

MixTestInteractive.run(System.argv())
```

As an example, let's assume you've named the script `mti_exec`.

Now you can `cd` to the project's root directory, and run `mti_exec`. The script
will accept all of `mix_test_interactive`'s [command-line options](#options) and
allow you to use any of its [interactive commands](#interactive-commands).

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

- `--(no-)ansi-enabled`: Enable ANSI (colored) output when running tests
  (default `false` on Windows; `true` on other platforms).
- `--(no-)clear`: Clear the console before each run (default `false`).
- `--command <command> [--arg <arg>]`: Custom command and arguments for running
  tests (default: "mix" with no arguments). NOTE: Use `--arg` multiple times to
  specify more than one argument.
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
- `--(no-)verbose`: Display the command to be run before running the tests
  (default: `false`).
- `--(no-)watch`: Don't run tests when a file changes (default: `true`).

All of the `<mix test arguments>` are passed through to `mix test` on every test
run.

`mix test.interactive` will detect the `--exclude`, `--failed`, `--include`,
`--only`, `--seed`, and `--stale` options and use those as initial settings in
interactive mode. You can then use the interactive mode commands to adjust those
options as needed. It will also detect any filename or pattern arguments and use
those as initial settings. Note that if you specify a pattern on the
command-line, `mix test.interactive` will find all test files matching that
pattern and pass those to `mix test` as if you had used the `p` command.

### Patterns and filenames

`mix test.interactive` can take the same filename or filename:line_number
patterns that `mix test` understands. It also allows you to specify one or more
"patterns" - strings that match one or more test files. When you provide one or
more patterns on the command-line, `mix test.interactive` will find all test
files matching those patterns and pass them to `mix test` as if you had used the
`p` command (described below).

## Interactive Commands

After the tests run, you can use the interactive commands to change which tests
will run.

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
test`).
- `x <tags...>`: Exclude tests tagged with the listed tags (equivalent to the
  `--exclude` option of `mix test`).
- `x`: Clear any excluded tags.
- `w`: Turn file-watching mode on or off.
- `Enter`: Re-run the current set of tests without requiring a file change.
- `?`: Show usage help.

## Configuration

`mix test.interactive` can be configured with various options using application
configuration. You can also use command line arguments to specify these
configuration options, or to override configured options.

### `ansi_enabled`: Enable ANSI (colored) output when running tests

When `ansi_enabled` is set to true, `mix test.interactive` will enable ANSI
output when running tests, allowing for `mix test`'s normal colored output.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    ansi_enabled: false
end
```

The default is `false` on Windows and `true` on other platforms.

### `clear`: Clear the console before each run

If you want `mix test.interactive` to clear the console before each run, you can
enable this option in your config/dev.exs as follows:

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    clear: true
end
```

### `command`: Use a custom command

By default, `mix test.interactive` uses `mix test` to run tests.

You might want to provide a custom command that does other things before or
after running `mix`. In that case, you can customize the command used for
running tests.

For example, you might want to provide a name for the test runner process to
allow connection from other Erlang nodes. Or you might want to run other
commands before or after running the tests.

In those cases, you can customize the command that `mix test.interactive` will
use to run your tests. `mix test.interactive` assumes that the custom command
ultimately runs `mix` under the hood (or at least accepts all of the same
command-line arguments as `mix`). The custom command can either be a string or a
`{command, [..args..]}` tuple.

Examples:

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    command: "path/to/my/test_runner.sh"
end
```

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    command: {"elixir", ["--sname", "name", "-S", "mix"]}
end
```

To run a different mix task instead, see the `task` option below.

### `exclude`: Excluding files or directories

To stop changes to specific files or directories from triggering test runs, you
can add `exclude:` regexp patterns to your config in `mix.exs`:

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    exclude: [~r/db_migration\/.*/,
              ~r/useless_.*\.exs/]
end
```

The default is `exclude: [~r/\.#/, ~r{priv/repo/migrations}]`.

### `extra_extensions`: Watch files with additional extensions

By default, `mix test.interactive` will trigger a test run when a known Elixir
or Erlang file has changed, but not when any other file changes.

You can specify additional file extensions to be included with the
`extra_extensions` option.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    extra_extensions: ["json"]
end
```

`mix test.interactive` always watches files with the following extensions:
`.erl`, `.ex`, `.exs`, `.eex`, `.leex`, `.heex`, `.xrl`, `.yrl`, and `.hrl`. To
ignore files with any of these extensions, you can specify an `exclude` regexp
(see above).

### `runner`: Use a custom runner module

By default `mix test.interactive` uses an internal module named
`MixTestInteractive.PortRunner` to run the tests. If you want to run the tests
in a different way, you can supply your own runner module instead. Your module
must implement the `MixTestInteractive.TestRunner` behaviour, either implicitly
or explicitly.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    runner: MyApp.FancyTestRunner
end
```

### `task`: Run a different mix task

By default, `mix test.interactive` runs `mix test`.

Through the mix config it is possible to run a different mix task. `mix
test.interactive` assumes that this alternative task accepts the same
command-line arguments as `mix test`.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    task: "custom_test_task"
end
```

The task is run with `MIX_ENV` set to `test`.

To use a custom command instead, see the `command` option above.

### `timestamp`: Display the current time before running the tests

When `timestamp` is set to true, `mix test.interactive` will display the current
time (UTC) just before running the tests.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    timestamp: true
end
```

### `verbose`: Display the command to be run before running the tests

When `verbose` is set to true, `mix test.interactive` will display the command
line it is about to execute just before running the tests.

```elixir
# config/config.exs
import Config

if Mix.env == :dev do
  config :mix_test_interactive,
    verbose: true
end
```

## Compatibility Notes

On Linux you may need to install `inotify-tools`.

## Desktop Notifications

You can enable desktop notifications with
[ex_unit_notifier](https://github.com/navinpeiris/ex_unit_notifier).

## Acknowledgements

This project started as a clone of the wonderful
[mix-test.watch](https://github.com/lpil/mix-test.watch) project, which I've
used and loved for years. I've added the interactive mode features to the
existing feature set.

The idea for having an interactive mode comes from [Jest](https://jestjs.io/)
and its incredibly useful interactive watch mode.

## Copyright and License

Copyright (c) 2021-2024 Randy Coulman

This work is free. You can redistribute it and/or modify it under the terms of
the MIT License. See the [LICENSE.md](./LICENSE.md) file for more details.
