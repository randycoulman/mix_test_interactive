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

Use the `p` command to run only a subset of your test files:

```
p file1 file2
```

Use the `c` command to clear the file filter and run all test files again.

Use the `s` command to run only test files that reference modules that have changed since the last run (equivalent to the `--stale` option of `mix test`).

Use the `f` command to run only tests that failed on the last run (equivalent to the `--failed` option of `mix test`).

Use the `a` command to clear the `s` and/or `f` flags and run all tests again.

Use the `Enter` key to re-run the current set of tests without requiring a file change.

Use the `q` command, or press `Ctrl-D` to exit the program.

## Running Additional Mix Tasks

Through the mix config it is possible to run other mix tasks as well as the
test task. For example, if I wished to run the [Dogma][dogma] code style
linter after my tests I would do so like this.

[dogma]: https://github.com/lpil/dogma

```elixir
# config/config.exs
use Mix.Config

if Mix.env == :dev do
  config :mix_test_interactive,
    tasks: [
      "test",
      "dogma",
    ]
end
```

Tasks are run in the order they appear in the list, and the progression will
stop if any command returns a non-zero exit code.

All tasks are run with `MIX_ENV` set to `test`.

## Passing Arguments To Tasks

Any command line arguments passed to the `mix test.interactive` task will be passed
through to all of the tasks being run, along with any arguments added by interactive mode. If I want to see detailed trace information for my tests, I can run:

```
mix test.interactive --trace
```

Note that if you have configured more than one task to be run, these arguments
will be passed to all the tasks run, not just the test command.

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
