defmodule MixTestInteractive.SettingsTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Settings

  describe "watch mode" do
    test "enabled by default" do
      settings = Settings.new()

      assert settings.watching?
    end

    test "disables with --no-watch flag" do
      settings = Settings.new(["--no-watch"])
      refute settings.watching?
    end

    test "consumes --watch flag" do
      settings = Settings.new(["--watch"])
      assert {:ok, []} = Settings.cli_args(settings)
    end

    test "consumes --no-watch flag" do
      settings = Settings.new(["--no-watch"])
      assert {:ok, []} = Settings.cli_args(settings)
    end

    test "toggles off" do
      settings =
        Settings.toggle_watch_mode(Settings.new())

      refute settings.watching?
    end

    test "toggles back on" do
      settings =
        Settings.new()
        |> Settings.toggle_watch_mode()
        |> Settings.toggle_watch_mode()

      assert settings.watching?
    end
  end

  describe "command line arguments" do
    test "passes on provided arguments" do
      settings = Settings.new(["--trace", "--raise"])
      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--raise"]
    end

    test "passes no arguments by default" do
      settings = Settings.new()
      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "omits unknown arguments" do
      settings = Settings.new(["--unknown-arg"])

      assert settings.initial_cli_args == []
    end

    test "initializes stale flag from arguments" do
      settings = Settings.new(["--trace", "--stale", "--raise"])
      assert settings.stale?
      assert settings.initial_cli_args == ["--trace", "--raise"]
    end

    test "initializes failed flag from arguments" do
      settings = Settings.new(["--trace", "--failed", "--raise"])
      assert settings.failed?
      assert settings.initial_cli_args == ["--trace", "--raise"]
    end

    test "initializes patterns from arguments" do
      settings = Settings.new(["pattern1", "--trace", "pattern2"])
      assert settings.patterns == ["pattern1", "pattern2"]
      assert settings.initial_cli_args == ["--trace"]
    end

    test "failed takes precedence to stale" do
      settings = Settings.new(["--failed", "--stale"])
      refute settings.stale?
      assert settings.failed?
    end

    test "patterns take precedence to stale/failed flags" do
      settings = Settings.new(["--failed", "--stale", "pattern"])
      assert settings.patterns == ["pattern"]
      refute settings.failed?
      refute settings.stale?
      assert settings.initial_cli_args == []
    end
  end

  describe "filtering tests" do
    test "filters to files matching patterns" do
      all_files = ~w(file1 file2 no_match other)

      settings =
        ["--trace"]
        |> Settings.new()
        |> with_fake_file_list(all_files)
        |> Settings.only_patterns(["file", "other"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "file1", "file2", "other"]
    end

    test "returns error if no files match pattern" do
      settings =
        Settings.new()
        |> with_fake_file_list([])
        |> Settings.only_patterns(["file"])

      assert {:error, :no_matching_files} = Settings.cli_args(settings)
    end

    test "restricts to failed tests" do
      settings =
        ["--trace"]
        |> Settings.new()
        |> Settings.only_failed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--failed"]
    end

    test "restricts to stale tests" do
      settings =
        ["--trace"]
        |> Settings.new()
        |> Settings.only_stale()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--stale"]
    end

    test "pattern filter clears failed flag" do
      settings =
        Settings.new()
        |> with_fake_file_list(["file"])
        |> Settings.only_failed()
        |> Settings.only_patterns(["f"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["file"]
    end

    test "pattern filter clears stale flag" do
      settings =
        Settings.new()
        |> with_fake_file_list(["file"])
        |> Settings.only_stale()
        |> Settings.only_patterns(["f"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["file"]
    end

    test "failed flag clears pattern filters" do
      settings =
        Settings.new()
        |> Settings.only_patterns(["file"])
        |> Settings.only_failed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--failed"]
    end

    test "failed flag clears stale flag" do
      settings =
        Settings.new()
        |> Settings.only_stale()
        |> Settings.only_failed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--failed"]
    end

    test "stale flag clears pattern filters" do
      settings =
        Settings.new()
        |> Settings.only_patterns(["file"])
        |> Settings.only_stale()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--stale"]
    end

    test "stale flag clears failed flag" do
      settings =
        Settings.new()
        |> Settings.only_failed()
        |> Settings.only_stale()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--stale"]
    end

    test "all tests clears pattern filters" do
      settings =
        Settings.new()
        |> Settings.only_patterns(["pattern"])
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests removes stale flag" do
      settings =
        Settings.new()
        |> Settings.only_stale()
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests removes failed flag" do
      settings =
        Settings.new()
        |> Settings.only_failed()
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    defp with_fake_file_list(settings, files) do
      Settings.list_files_with(settings, fn -> files end)
    end
  end

  describe "summary" do
    test "ran all tests" do
      settings = Settings.new()

      assert Settings.summary(settings) == "Ran all tests"
    end

    test "ran failed tests" do
      settings = Settings.only_failed(Settings.new())

      assert Settings.summary(settings) == "Ran only failed tests"
    end

    test "ran stale tests" do
      settings = Settings.only_stale(Settings.new())

      assert Settings.summary(settings) == "Ran only stale tests"
    end

    test "ran specific patterns" do
      settings = Settings.only_patterns(Settings.new(), ["p1", "p2"])

      assert Settings.summary(settings) == "Ran all test files matching p1, p2"
    end
  end
end
