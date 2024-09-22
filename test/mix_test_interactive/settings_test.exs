defmodule MixTestInteractive.SettingsTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Settings

  describe "filtering test files" do
    test "filters to files matching patterns" do
      all_files = ~w(file1 file2 no_match other)

      settings =
        %Settings{initial_cli_args: ["--color"]}
        |> with_fake_file_list(all_files)
        |> Settings.only_patterns(["file", "other"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "file1", "file2", "other"]
    end

    test "returns error if no files match pattern" do
      settings =
        %Settings{}
        |> with_fake_file_list([])
        |> Settings.only_patterns(["file"])

      assert {:error, :no_matching_files} = Settings.cli_args(settings)
    end

    test "restricts to failed tests" do
      settings =
        Settings.only_failed(%Settings{initial_cli_args: ["--color"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--failed"]
    end

    test "restricts to stale tests" do
      settings =
        Settings.only_stale(%Settings{initial_cli_args: ["--color"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--stale"]
    end

    test "pattern filter clears failed flag" do
      settings =
        %Settings{}
        |> with_fake_file_list(["file"])
        |> Settings.only_failed()
        |> Settings.only_patterns(["f"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["file"]
    end

    test "pattern filter clears stale flag" do
      settings =
        %Settings{}
        |> with_fake_file_list(["file"])
        |> Settings.only_stale()
        |> Settings.only_patterns(["f"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["file"]
    end

    test "failed flag clears pattern filters" do
      settings =
        %Settings{}
        |> Settings.only_patterns(["file"])
        |> Settings.only_failed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--failed"]
    end

    test "failed flag clears stale flag" do
      settings =
        %Settings{}
        |> Settings.only_stale()
        |> Settings.only_failed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--failed"]
    end

    test "stale flag clears pattern filters" do
      settings =
        %Settings{}
        |> Settings.only_patterns(["file"])
        |> Settings.only_stale()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--stale"]
    end

    test "stale flag clears failed flag" do
      settings =
        %Settings{}
        |> Settings.only_failed()
        |> Settings.only_stale()

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--stale"]
    end

    test "all tests clears pattern filters" do
      settings =
        %Settings{}
        |> Settings.only_patterns(["pattern"])
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests removes stale flag" do
      settings =
        %Settings{}
        |> Settings.only_stale()
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests removes failed flag" do
      settings =
        %Settings{}
        |> Settings.only_failed()
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    defp with_fake_file_list(settings, files) do
      Settings.list_files_with(settings, fn -> files end)
    end
  end

  describe "filtering tests by tags" do
    test "excludes specified tags" do
      tags = ["tag1", "tag2"]
      settings = Settings.with_excludes(%Settings{initial_cli_args: ["--color"]}, tags)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--exclude", "tag1", "--exclude", "tag2"]
    end

    test "clears excluded tags" do
      settings =
        %Settings{}
        |> Settings.with_excludes(["tag1"])
        |> Settings.clear_excludes()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "includes specified tags" do
      tags = ["tag1", "tag2"]
      settings = Settings.with_includes(%Settings{initial_cli_args: ["--color"]}, tags)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--include", "tag1", "--include", "tag2"]
    end

    test "clears included tags" do
      settings =
        %Settings{}
        |> Settings.with_includes(["tag1"])
        |> Settings.clear_includes()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "runs only specified tags" do
      tags = ["tag1", "tag2"]
      settings = Settings.with_only(%Settings{initial_cli_args: ["--color"]}, tags)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--only", "tag1", "--only", "tag2"]
    end

    test "clears only tags" do
      settings =
        %Settings{}
        |> Settings.with_only(["tag1"])
        |> Settings.clear_only()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "specifying maximum failures" do
    test "stops after a specified number of failures" do
      max = "3"
      settings = Settings.with_max_failures(%Settings{initial_cli_args: ["--color"]}, max)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--max-failures", max]
    end

    test "clears maximum failures" do
      settings =
        %Settings{}
        |> Settings.with_max_failures("2")
        |> Settings.clear_max_failures()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "repeating until failure" do
    test "re-runs up to specified times until failure" do
      count = "56"
      settings = Settings.with_repeat_count(%Settings{initial_cli_args: ["--color"]}, count)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--repeat-until-failure", count]
    end

    test "clears the repeat count" do
      settings =
        %Settings{}
        |> Settings.with_repeat_count("12")
        |> Settings.clear_repeat_count()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "specifying the seed" do
    test "runs with seed" do
      seed = "5678"
      settings = Settings.with_seed(%Settings{initial_cli_args: ["--color"]}, seed)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--seed", seed]
    end

    test "clears the seed" do
      settings =
        %Settings{}
        |> Settings.with_seed("1234")
        |> Settings.clear_seed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "tracing the test run" do
    test "toggles tracing on" do
      settings = Settings.toggle_tracing(%Settings{initial_cli_args: ["--color"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--trace"]
    end

    test "toggles tracing off" do
      settings =
        %Settings{}
        |> Settings.toggle_tracing()
        |> Settings.toggle_tracing()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end
end
