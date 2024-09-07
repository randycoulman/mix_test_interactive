defmodule MixTestInteractive.CommandLineParserTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.CommandLineParser
  alias MixTestInteractive.Settings

  describe "watch mode" do
    test "enables with --watch flag" do
      %Settings{} = settings = CommandLineParser.parse(["--watch"])
      assert settings.watching?
    end

    test "disables with --no-watch flag" do
      %Settings{} = settings = CommandLineParser.parse(["--no-watch"])
      refute settings.watching?
    end

    test "consumes --watch flag" do
      %Settings{} = settings = CommandLineParser.parse(["--watch"])
      assert {:ok, []} = Settings.cli_args(settings)
    end

    test "consumes --no-watch flag" do
      %Settings{} = settings = CommandLineParser.parse(["--no-watch"])
      assert {:ok, []} = Settings.cli_args(settings)
    end
  end

  describe "mix test arguments" do
    test "records initial `mix test` arguments" do
      %Settings{} = settings = CommandLineParser.parse(["--trace", "--raise"])
      assert settings.initial_cli_args == ["--trace", "--raise"]
    end

    test "records no `mix test` arguments by default" do
      %Settings{} = settings = CommandLineParser.parse()
      assert settings.initial_cli_args == []
    end

    test "omits unknown arguments" do
      %Settings{} = settings = CommandLineParser.parse(["--unknown-arg"])

      assert settings.initial_cli_args == []
    end

    test "extracts stale setting from arguments" do
      %Settings{} = settings = CommandLineParser.parse(["--trace", "--stale", "--raise"])
      assert settings.stale?
      assert settings.initial_cli_args == ["--trace", "--raise"]
    end

    test "extracts failed flag from arguments" do
      %Settings{} = settings = CommandLineParser.parse(["--trace", "--failed", "--raise"])
      assert settings.failed?
      assert settings.initial_cli_args == ["--trace", "--raise"]
    end

    test "extracts patterns from arguments" do
      %Settings{} = settings = CommandLineParser.parse(["pattern1", "--trace", "pattern2"])
      assert settings.patterns == ["pattern1", "pattern2"]
      assert settings.initial_cli_args == ["--trace"]
    end

    test "failed takes precedence over stale" do
      %Settings{} = settings = CommandLineParser.parse(["--failed", "--stale"])
      refute settings.stale?
      assert settings.failed?
    end

    test "patterns take precedence over stale/failed flags" do
      %Settings{} = settings = CommandLineParser.parse(["--failed", "--stale", "pattern"])
      assert settings.patterns == ["pattern"]
      refute settings.failed?
      refute settings.stale?
      assert settings.initial_cli_args == []
    end
  end
end
