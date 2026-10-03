defmodule MixTestInteractive.SettingsTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Settings

  describe "running only failed tests" do
    test "toggles failed tests on" do
      settings = Settings.toggle_failed(%Settings{initial_cli_args: ["--color"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--failed"]
    end

    test "toggles failed tests off" do
      settings =
        %Settings{}
        |> Settings.toggle_failed()
        |> Settings.toggle_failed()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests removes failed flag" do
      settings =
        %Settings{}
        |> Settings.toggle_failed()
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "running only stale tests" do
    test "toggles stale tests on" do
      settings = Settings.toggle_stale(%Settings{initial_cli_args: ["--color"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--stale"]
    end

    test "toggles stale tests off" do
      settings =
        %Settings{}
        |> Settings.toggle_stale()
        |> Settings.toggle_stale()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests removes stale flag" do
      settings =
        %Settings{}
        |> Settings.toggle_stale()
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end
  end

  describe "filtering tests by filename patterns" do
    test "filters to files matching filename patterns" do
      all_files = ~w(file1 file2 no_match other)

      settings =
        %Settings{initial_cli_args: ["--color"]}
        |> with_fake_file_list(all_files)
        |> Settings.with_filename_patterns(["file", "other"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "file1", "file2", "other"]
    end

    test "returns error if no files match filename pattern" do
      settings =
        %Settings{}
        |> with_fake_file_list([])
        |> Settings.with_filename_patterns(["file"])

      assert {:error, :no_matching_files} = Settings.cli_args(settings)
    end

    test "empty filename pattern list clears filename patterns" do
      settings =
        %Settings{}
        |> Settings.with_filename_patterns(["pattern"])
        |> Settings.with_filename_patterns([])

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests clears filename patterns" do
      settings =
        %Settings{}
        |> Settings.with_filename_patterns(["pattern"])
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    defp with_fake_file_list(settings, files) do
      Settings.list_files_with(settings, fn -> files end)
    end
  end

  describe "filtering tests by name pattern" do
    test "runs tests matching the name pattern" do
      settings = Settings.with_name_pattern(%Settings{initial_cli_args: ["--color"]}, "does a thing")

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--name-pattern", "does a thing"]
    end

    test "clears the name pattern" do
      settings =
        %Settings{}
        |> Settings.with_name_pattern("does a thing")
        |> Settings.clear_name_pattern()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests clears the name pattern" do
      settings =
        %Settings{}
        |> Settings.with_name_pattern("does a thing")
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
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

    test "all tests clears excludes" do
      settings =
        %Settings{}
        |> Settings.with_excludes(["tag1"])
        |> Settings.all_tests()

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

    test "all tests clears includes" do
      settings =
        %Settings{}
        |> Settings.with_includes(["tag1"])
        |> Settings.all_tests()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "runs only specified tags" do
      tags = ["tag1", "tag2"]
      settings = Settings.with_only(%Settings{initial_cli_args: ["--color"]}, tags)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--color", "--only", "tag1", "--only", "tag2"]
    end

    test "clears 'only' tags" do
      settings =
        %Settings{}
        |> Settings.with_only(["tag1"])
        |> Settings.clear_only()

      {:ok, args} = Settings.cli_args(settings)
      assert args == []
    end

    test "all tests clears 'only' tags" do
      settings =
        %Settings{}
        |> Settings.with_only(["tag1"])
        |> Settings.all_tests()

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

  describe "checking whether all tests run" do
    test "runs all tests by default" do
      assert Settings.all_tests?(%Settings{})
    end

    test "does not run all tests when a selection setting is active" do
      refute Settings.all_tests?(Settings.toggle_failed(%Settings{}))
    end

    test "runs all tests after all tests clears selection settings" do
      settings =
        %Settings{}
        |> Settings.toggle_stale()
        |> Settings.with_only(["tag1"])
        |> Settings.all_tests()

      assert Settings.all_tests?(settings)
    end

    test "ignores settings that don't select tests" do
      settings =
        %Settings{}
        |> Settings.with_max_failures("3")
        |> Settings.with_repeat_count("10")
        |> Settings.with_seed("4258")
        |> Settings.toggle_tracing()
        |> Settings.toggle_watch_mode()

      assert Settings.all_tests?(settings)
    end
  end
end
