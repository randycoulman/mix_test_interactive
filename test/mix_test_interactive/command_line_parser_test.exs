defmodule MixTestInteractive.CommandLineParserTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias MixTestInteractive.CommandLineParser

  describe "mix test.interactive options" do
    test "sets clear? flag with --clear" do
      {config, _settings} = CommandLineParser.parse(["--clear"])
      assert config.clear?
    end

    test "clears clear? flag with --no-clear" do
      {config, _settings} = CommandLineParser.parse(["--no-clear"])
      refute config.clear?
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
      {_config, settings} = CommandLineParser.parse(["--clear", "--no-clear", "--watch", "--no-watch"])
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
