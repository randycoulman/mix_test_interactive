defmodule MixTestInteractive.CommandLineParserTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias MixTestInteractive.CommandLineParser
  alias MixTestInteractive.Config

  defmodule CustomRunner do
    @moduledoc false
    def run(_config, _args), do: :noop
  end

  defmodule NotARunner do
    @moduledoc false
  end

  describe "mix test.interactive options" do
    test "retains original defaults when no options" do
      {config, _settings} = CommandLineParser.parse([])
      assert config == %Config{}
    end

    test "sets clear? flag with --clear" do
      {config, _settings} = CommandLineParser.parse(["--clear"])
      assert config.clear?
    end

    test "clears clear? flag with --no-clear" do
      {config, _settings} = CommandLineParser.parse(["--no-clear"])
      refute config.clear?
    end

    test "configures custom command with --command" do
      {config, _settings} = CommandLineParser.parse(["--command", "custom_command"])
      assert config.command == {"custom_command", []}
    end

    test "configures custom command with single argument with --command and --arg" do
      {config, _settings} = CommandLineParser.parse(["--command", "custom_command", "--arg", "custom_arg"])
      assert config.command == {"custom_command", ["custom_arg"]}
    end

    test "configures custom command with multiple arguments with --command and repeated --arg options" do
      {config, _settings} =
        CommandLineParser.parse(["--command", "custom_command", "--arg", "custom_arg1", "--arg", "custom_arg2"])

      assert config.command == {"custom_command", ["custom_arg1", "custom_arg2"]}
    end

    test "ignores custom command arguments if command is not specified" do
      {config, _settings} = CommandLineParser.parse(["--arg", "arg_with_missing_command"])
      assert config.command == %Config{}.command
    end

    test "configures watch exclusions with --exclude" do
      {config, _settings} = CommandLineParser.parse(["--exclude", "~$"])
      assert config.exclude == [~r/~$/]
    end

    test "configures multiple watch exclusions with repeated --exclude options" do
      {config, _settings} = CommandLineParser.parse(["--exclude", "~$", "--exclude", "\.secret\.exs"])
      assert config.exclude == [~r/~$/, ~r/.secret.exs/]
    end

    test "fails if watch exclusion is an invalid Regex" do
      assert_raise Regex.CompileError, fn ->
        CommandLineParser.parse(["--exclude", "[A-Za-z"])
      end
    end

    test "configures additional extensions to watch with --extra-extensions" do
      {config, _settings} = CommandLineParser.parse(["--extra-extensions", "md"])
      assert config.extra_extensions == ["md"]
    end

    test "configures multiple additional extensions to watch with repeated --extra-extensions options" do
      {config, _settings} = CommandLineParser.parse(["--extra-extensions", "md", "--extra-extensions", "json"])
      assert config.extra_extensions == ["md", "json"]
    end

    test "configures custom runner module with --runner" do
      {config, _setting} = CommandLineParser.parse(["--runner", inspect(CustomRunner)])
      assert config.runner == CustomRunner
    end

    test "fails if custom runner doesn't have a run function" do
      assert_raise ArgumentError, fn ->
        CommandLineParser.parse(["--runner", inspect(NotARunner)])
      end
    end

    test "fails if custom runner module doesn't exist" do
      assert_raise ArgumentError, fn ->
        CommandLineParser.parse(["--runner", "NotAModule"])
      end
    end

    test "sets show_timestamp? flag with --timestamp" do
      {config, _settings} = CommandLineParser.parse(["--timestamp"])
      assert config.show_timestamp?
    end

    test "clears show_timestamp? flag with --no-timestamp" do
      {config, _settings} = CommandLineParser.parse(["--no-timestamp"])
      refute config.show_timestamp?
    end

    test "configures custom mix task with --task" do
      {config, _settings} = CommandLineParser.parse(["--task", "custom_task"])
      assert config.task == "custom_task"
    end

    test "initially enables watch mode with --watch flag" do
      {_config, settings} = CommandLineParser.parse(["--watch"])
      assert settings.watching?
    end

    test "initially disables watch mode with --no-watch flag" do
      {_config, settings} = CommandLineParser.parse(["--no-watch"])
      refute settings.watching?
    end

    test "does not pass mti options to mix test" do
      {_config, settings} =
        CommandLineParser.parse([
          "--clear",
          "--no-clear",
          "--command",
          "custom_command",
          "--arg",
          "--custom_arg",
          "--exclude",
          "~$",
          "--extra-extensions",
          "md",
          "--runner",
          inspect(CustomRunner),
          "--timestamp",
          "--no-timestamp",
          "--watch",
          "--no-watch"
        ])

      assert settings.initial_cli_args == []
    end
  end

  describe "mix test arguments" do
    test "records initial `mix test` arguments" do
      {_config, settings} = CommandLineParser.parse(["--trace", "--raise"])
      assert settings.initial_cli_args == ["--trace", "--raise"]
    end

    test "records no `mix test` arguments by default" do
      {_config, settings} = CommandLineParser.parse()
      assert settings.initial_cli_args == []
    end

    test "omits unknown arguments" do
      {_config, settings} = CommandLineParser.parse(["--unknown-arg"])

      assert settings.initial_cli_args == []
    end

    test "extracts stale setting from arguments" do
      {_config, settings} = CommandLineParser.parse(["--trace", "--stale", "--raise"])
      assert settings.stale?
      assert settings.initial_cli_args == ["--trace", "--raise"]
    end

    test "extracts failed flag from arguments" do
      {_config, settings} = CommandLineParser.parse(["--trace", "--failed", "--raise"])
      assert settings.failed?
      assert settings.initial_cli_args == ["--trace", "--raise"]
    end

    test "extracts patterns from arguments" do
      {_config, settings} = CommandLineParser.parse(["pattern1", "--trace", "pattern2"])
      assert settings.patterns == ["pattern1", "pattern2"]
      assert settings.initial_cli_args == ["--trace"]
    end

    test "failed takes precedence over stale" do
      {_config, settings} = CommandLineParser.parse(["--failed", "--stale"])
      refute settings.stale?
      assert settings.failed?
    end

    test "patterns take precedence over stale/failed flags" do
      {_config, settings} = CommandLineParser.parse(["--failed", "--stale", "pattern"])
      assert settings.patterns == ["pattern"]
      refute settings.failed?
      refute settings.stale?
      assert settings.initial_cli_args == []
    end
  end

  describe "passing both mix test.interactive (mti) and mix test arguments" do
    test "process arguments for mti and mix test separately" do
      {config, settings} = CommandLineParser.parse(["--clear", "--", "--stale"])
      assert config.clear?
      assert settings.stale?
    end

    test "handles mti and mix test options with the same name" do
      {config, settings} = CommandLineParser.parse(["--exclude", "~$", "--", "--exclude", "integration"])
      assert config.exclude == [~r/~$/]
      assert settings.initial_cli_args == ["--exclude", "integration"]
    end

    test "requires -- separator to distinguish the sets of arguments" do
      {config, settings} = CommandLineParser.parse(["--clear", "--stale"])
      assert config.clear?
      refute settings.stale?
    end

    test "handles mix test options with leading `--` separator" do
      {_config, settings} = CommandLineParser.parse(["--", "--stale"])
      assert settings.stale?
    end

    test "displays deprecation warning if --{no-}watch specified in mix test options" do
      {{_config, settings}, output} =
        with_io(:stderr, fn ->
          CommandLineParser.parse(["--", "--no-watch"])
        end)

      assert output =~ "DEPRECATION WARNING"
      refute settings.watching?
    end

    test "watch flag from mti options takes precedence over the flag from mix test options, but still displays deprecation warning" do
      {{_config, settings}, output} =
        with_io(:stderr, fn ->
          CommandLineParser.parse(["--no-watch", "--", "--watch"])
        end)

      assert output =~ "DEPRECATION WARNING"
      refute settings.watching?
    end

    test "omits unknown options before --" do
      {_config, settings} = CommandLineParser.parse(["--unknown-arg", "--", "--stale"])

      assert settings.stale?
    end

    test "omits unknown options after --" do
      {config, _settings} = CommandLineParser.parse(["--clear", "--", "--unknown-arg"])

      assert config.clear?
    end
  end
end
