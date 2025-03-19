defmodule MixTestInteractive.CommandLineParserTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.CommandLineParser
  alias MixTestInteractive.CommandLineParser.UsageError
  alias MixTestInteractive.Config

  defmodule CustomRunner do
    @moduledoc false
    @behaviour MixTestInteractive.TestRunner

    alias MixTestInteractive.TestRunner

    @impl TestRunner
    def run(_config, _args), do: :ok
  end

  defmodule NotARunner do
    @moduledoc false
  end

  describe "help option" do
    test "returns :help with --help" do
      assert {:ok, :help} == CommandLineParser.parse(["--help"])
    end

    test "returns :help even with other options" do
      assert {:ok, :help} == CommandLineParser.parse(["--clear", "--help", "--no-watch"])
    end

    test "returns :help even with unknown options" do
      assert {:ok, :help} == CommandLineParser.parse(["--unknown", "--help"])
    end

    test "returns :help even with mix test options only" do
      assert {:ok, :help} == CommandLineParser.parse(["--stale", "--help"])
    end
  end

  describe "version option" do
    test "returns :version with --version" do
      assert {:ok, :version} == CommandLineParser.parse(["--version"])
    end

    test "returns :help with both --help and --version" do
      assert {:ok, :help} == CommandLineParser.parse(["--version", "--help"])
    end

    test "returns :version even with other options" do
      assert {:ok, :version} == CommandLineParser.parse(["--clear", "--version", "--no-watch"])
    end

    test "returns :version even with unknown options" do
      assert {:ok, :version} == CommandLineParser.parse(["--unknown", "--version"])
    end

    test "returns :version even with mix test options only" do
      assert {:ok, :version} == CommandLineParser.parse(["--stale", "--version"])
    end
  end

  describe "mix test.interactive options" do
    test "retains original defaults when no options" do
      {:ok, %{config: config}} = CommandLineParser.parse([])
      assert config == Config.new()
    end

    test "sets ansi_enabled? flag with --ansi-enabled" do
      Process.put(:os_type, {:win32, :nt})
      {:ok, %{config: config}} = CommandLineParser.parse(["--ansi-enabled"])
      assert config.ansi_enabled?
    end

    test "clears ansi_enabled? flag with --no-ansi-enabled" do
      Process.put(:os_type, {:unix, :darwin})
      {:ok, %{config: config}} = CommandLineParser.parse(["--no-ansi-enabled"])
      refute config.ansi_enabled?
    end

    test "sets clear? flag with --clear" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--clear"])
      assert config.clear?
    end

    test "clears clear? flag with --no-clear" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--no-clear"])
      refute config.clear?
    end

    test "configures custom command with --command" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--command", "custom_command"])
      assert config.command == {"custom_command", []}
    end

    test "configures custom command with single argument with --command and --arg" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--command", "custom_command", "--arg", "custom_arg"])
      assert config.command == {"custom_command", ["custom_arg"]}
    end

    test "configures custom command with multiple arguments with --command and repeated --arg options" do
      {:ok, %{config: config}} =
        CommandLineParser.parse(["--command", "custom_command", "--arg", "custom_arg1", "--arg", "custom_arg2"])

      assert config.command == {"custom_command", ["custom_arg1", "custom_arg2"]}
    end

    test "ignores custom command arguments if command is not specified" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--arg", "arg_with_missing_command"])
      assert config.command == %Config{}.command
    end

    test "configures watch exclusions with --exclude" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--exclude", "~$"])
      assert config.exclude == [~r/~$/]
    end

    test "configures multiple watch exclusions with repeated --exclude options" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--exclude", "~$", "--exclude", "\.secret\.exs"])
      assert config.exclude == [~r/~$/, ~r/.secret.exs/]
    end

    test "fails if watch exclusion is an invalid Regex" do
      assert {:error, %UsageError{}} = CommandLineParser.parse(["--exclude", "[A-Za-z"])
    end

    test "configures additional extensions to watch with --extra-extensions" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--extra-extensions", "md"])
      assert config.extra_extensions == ["md"]
    end

    test "configures multiple additional extensions to watch with repeated --extra-extensions options" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--extra-extensions", "md", "--extra-extensions", "json"])
      assert config.extra_extensions == ["md", "json"]
    end

    test "configures custom runner module with --runner" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--runner", inspect(CustomRunner)])
      assert config.runner == CustomRunner
    end

    test "fails if custom runner doesn't have a run function" do
      assert {:error, %UsageError{}} = CommandLineParser.parse(["--runner", inspect(NotARunner)])
    end

    test "fails if custom runner module doesn't exist" do
      assert {:error, %UsageError{}} = CommandLineParser.parse(["--runner", "NotAModule"])
    end

    test "sets show_timestamp? flag with --timestamp" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--timestamp"])
      assert config.show_timestamp?
    end

    test "clears show_timestamp? flag with --no-timestamp" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--no-timestamp"])
      refute config.show_timestamp?
    end

    test "configures custom mix task with --task" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--task", "custom_task"])
      assert config.task == "custom_task"
    end

    test "initially enables watch mode with --watch flag" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--watch"])
      assert settings.watching?
    end

    test "initially disables watch mode with --no-watch flag" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--no-watch"])
      refute settings.watching?
    end

    test "does not pass mti options to mix test" do
      {:ok, %{settings: settings}} =
        CommandLineParser.parse([
          "--clear",
          "--no-clear",
          "--command",
          "custom_command",
          "--arg",
          "custom_arg",
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
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--color", "--raise"])
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "records no `mix test` arguments by default" do
      {:ok, %{settings: settings}} = CommandLineParser.parse()
      assert settings.initial_cli_args == []
    end

    test "omits unknown arguments" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--unknown-arg"])

      assert settings.initial_cli_args == []
    end

    test "extracts excludes from arguments" do
      {:ok, %{settings: settings}} =
        CommandLineParser.parse([
          "--",
          "--exclude",
          "tag1",
          "--color",
          "--exclude",
          "tag2",
          "--failed",
          "--raise",
          "--exclude",
          "tag3"
        ])

      assert settings.excludes == ["tag1", "tag2", "tag3"]
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts failed flag from arguments" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--color", "--failed", "--raise"])
      assert settings.failed?
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts includes from arguments" do
      {:ok, %{settings: settings}} =
        CommandLineParser.parse([
          "--include",
          "tag1",
          "--color",
          "--include",
          "tag2",
          "--failed",
          "--raise",
          "--include",
          "tag3"
        ])

      assert settings.includes == ["tag1", "tag2", "tag3"]
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts max-failures from arguments" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--color", "--max-failures", "7", "--raise"])
      assert settings.max_failures == "7"
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts only from arguments" do
      {:ok, %{settings: settings}} =
        CommandLineParser.parse(["--only", "tag1", "--color", "--only", "tag2", "--failed", "--raise", "--only", "tag3"])

      assert settings.only == ["tag1", "tag2", "tag3"]
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts repeat-until-failure from arguments" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--color", "--repeat-until-failure", "1000", "--raise"])
      assert settings.repeat_count == "1000"
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts seed from arguments" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--color", "--seed", "5432", "--raise"])
      assert settings.seed == "5432"
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts stale setting from arguments" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--color", "--stale", "--raise"])
      assert settings.stale?
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts trace flag from arguments" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--color", "--trace", "--raise"])
      assert settings.tracing?
      assert settings.initial_cli_args == ["--color", "--raise"]
    end

    test "extracts patterns from arguments" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["pattern1", "--color", "pattern2"])
      assert settings.patterns == ["pattern1", "pattern2"]
      assert settings.initial_cli_args == ["--color"]
    end

    test "extracts patterns even when no other flags are present" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["pattern1", "pattern2"])
      assert settings.patterns == ["pattern1", "pattern2"]
      assert settings.initial_cli_args == []
    end

    test "failed takes precedence over stale" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--failed", "--stale"])
      refute settings.stale?
      assert settings.failed?
    end

    test "patterns take precedence over stale/failed flags" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--failed", "--stale", "pattern"])
      assert settings.patterns == ["pattern"]
      refute settings.failed?
      refute settings.stale?
      assert settings.initial_cli_args == []
    end
  end

  describe "passing both mix test.interactive (mti) and mix test arguments" do
    test "process arguments for mti and mix test separately" do
      {:ok, %{config: config, settings: settings}} = CommandLineParser.parse(["--clear", "--", "--stale"])
      assert config.clear?
      assert settings.stale?
    end

    test "handles mti and mix test options with the same name" do
      {:ok, %{config: config, settings: settings}} =
        CommandLineParser.parse(["--exclude", "~$", "--", "--exclude", "integration"])

      assert config.exclude == [~r/~$/]
      assert settings.excludes == ["integration"]
    end

    test "requires -- separator to distinguish the sets of arguments" do
      assert {:error, %UsageError{}} = CommandLineParser.parse(["--clear", "--stale"])
    end

    test "handles mix test options with leading `--` separator" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--", "--stale"])
      assert settings.stale?
    end

    test "ignores --{no-}watch if specified in mix test options" do
      {:ok, %{settings: settings}} = CommandLineParser.parse(["--", "--no-watch"])

      assert settings.watching?
    end

    test "fails with unknown options before --" do
      assert {:error, %UsageError{}} = CommandLineParser.parse(["--unknown-arg", "--", "--stale"])
    end

    test "omits unknown options after --" do
      {:ok, %{config: config}} = CommandLineParser.parse(["--clear", "--", "--unknown-arg"])

      assert config.clear?
    end
  end
end
