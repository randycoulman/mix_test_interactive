# mix test.interactive

[![Build Status](https://circleci.com/gh/randycoulman/mix_test_interactive.svg?style=shield)](https://app.circleci.com/pipelines/github/randycoulman/mix_test_interactive)

Interactive watch mode for Elixir's mix test.

## Installation

The package can be installed by adding `mix_test_interactive` to your list of dependencies in `mix.exs`. It is not yet published to `hex.pm`, so for now you'll have to reference it from its GitHub repository:

```elixir
def deps do
  [
    {:mix_test_interactive, github: "randycoulman/mix_test_interactive", branch: "main", only: :dev, runtime: false}
  ]
end
```

## Usage

Run the mix task:

```shell
mix test.interactive
```

Your tests will run immediately (and every time a file changes).

After the tests run, you can use the interactive mode to change which tests will run.

Use the `p` command to run only test files that match one or more provided patterns. A pattern is the project-root-relative path to a test file (with or without a line number specification) or a string that matches a portion of full pathname. e.g. `test/my_project/my_test.exs`, `test/my_project/my_test.exs:12:24` or `my`.

If any pattern contains a line number specification, all patterns are passed directly to `mix test`.

```
p pattern1 pattern 2
```

Use the `s` command to run only test files that reference modules that have changed since the last run (equivalent to the `--stale` option of `mix test`).

Use the `f` command to run only tests that failed on the last run (equivalent to the `--failed` option of `mix test`).

Use the `a` command to run all tests.

Use the `Enter` key to re-run the current set of tests without requiring a file change.

Use the `q` command, or press `Ctrl-D` to exit the program.

## Running A Different Mix Task

By default, `mix test.interactive` runs `mix test`. Through the mix config it is possible to run a different mix task. `mix test.interactive` assumes that this alternative task accepts the same command-line arguments as `mix test`.

```elixir
# config/config.exs
use Mix.Config

if Mix.env == :dev do
  config :mix_test_interactive,
    task: "custom_test_task"
end
```

The task is run with `MIX_ENV` set to `test`.

## Passing Arguments To Tasks

Any command line arguments passed to the `mix test.interactive` task will be passed
through to all of the tasks being run, along with any arguments added by interactive mode. If I want to see detailed trace information for my tests, I can run:

```
mix test.interactive --trace
```

`mix test.interactive` will detect the `--stale` and `--failed` arguments and use those as initial settings in interactive mode. You can then toggle those flags on and off as needed.

## Clearing The Console Before Each Run

If you want `mix test.interactive` to clear the console before each run, you can
enable this option in your config/dev.exs as follows:

```elixir
# config/config.exs
use Mix.Config

if Mix.env == :dev do
  config :mix_test_interactive,
    clear: true
end
```

## Excluding files or directories

To ignore changes from specific files or directories add `exclude:` regexp
patterns to your config in `mix.exs`:

```elixir
# config/config.exs
use Mix.Config

if Mix.env == :dev do
  config :mix_test_interactive,
    exclude: [~r/db_migration\/.*/,
              ~r/useless_.*\.exs/]
end
```

The default is `exclude: [~r/\.#/, ~r{priv/repo/migrations}]`.

## Compatibility Notes

On Linux you may need to install `inotify-tools`.

## Desktop Notifications

You can enable desktop notifications with
[ex_unit_notifier](https://github.com/navinpeiris/ex_unit_notifier).

## Acknowledgements

This project started as a clone of the wonderful [mix-test.watch](https://github.com/lpil/mix-test.watch) project, which I've used and loved for years. I've added the interactive mode features to the existing feature set.

The idea for having an interactive mode comes from [Jest](https://jestjs.io/) and its incredibly useful interactive watch mode.
