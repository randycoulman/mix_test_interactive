defmodule MixTestInteractive.SettingsTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Settings

  describe "filtering tests" do
    test "filters to files matching patterns" do
      all_files = ~w(file1 file2 no_match other)

      settings =
        %Settings{initial_cli_args: ["--trace"]}
        |> with_fake_file_list(all_files)
        |> Settings.only_patterns(["file", "other"])

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "file1", "file2", "other"]
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
        Settings.only_failed(%Settings{initial_cli_args: ["--trace"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--failed"]
    end

    test "restricts to stale tests" do
      settings =
        Settings.only_stale(%Settings{initial_cli_args: ["--trace"]})

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--stale"]
    end

    test "runs with seed" do
      seed = "5678"
      settings = Settings.with_seed(%Settings{initial_cli_args: ["--trace"]}, seed)

      {:ok, args} = Settings.cli_args(settings)
      assert args == ["--trace", "--seed", seed]
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

  describe "summary" do
    test "ran all tests" do
      settings = %Settings{}

      assert Settings.summary(settings) == "Ran all tests"
    end

    test "ran all tests with seed" do
      seed = "4242"
      settings = Settings.with_seed(%Settings{}, seed)

      assert Settings.summary(settings) == "Ran all tests with seed: #{seed}"
    end

    test "ran failed tests" do
      settings = Settings.only_failed(%Settings{})

      assert Settings.summary(settings) == "Ran only failed tests"
    end

    test "ran failed tests with seed" do
      seed = "4242"

      settings =
        %Settings{}
        |> Settings.only_failed()
        |> Settings.with_seed(seed)

      assert Settings.summary(settings) == "Ran only failed tests with seed: #{seed}"
    end

    test "ran stale tests" do
      settings = Settings.only_stale(%Settings{})

      assert Settings.summary(settings) == "Ran only stale tests"
    end

    test "ran stale tests with seed" do
      seed = "4242"

      settings =
        %Settings{}
        |> Settings.only_stale()
        |> Settings.with_seed(seed)

      assert Settings.summary(settings) == "Ran only stale tests with seed: #{seed}"
    end

    test "ran specific patterns with seed" do
      seed = "4242"

      settings =
        %Settings{}
        |> Settings.only_patterns(["p1", "p2"])
        |> Settings.with_seed(seed)

      assert Settings.summary(settings) == "Ran all test files matching p1, p2 with seed: #{seed}"
    end
  end
end
