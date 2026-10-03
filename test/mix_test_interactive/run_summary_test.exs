defmodule MixTestInteractive.RunSummaryTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.RunSummary
  alias MixTestInteractive.Settings

  describe "summary header" do
    test "ran all tests" do
      settings = %Settings{}

      assert RunSummary.from_settings(settings) == "Ran all tests"
    end

    test "ran selected tests with failed" do
      settings = Settings.toggle_failed(%Settings{})

      assert RunSummary.from_settings(settings) =~ ~r/\ARan selected tests:\n/
    end

    test "ran selected tests with stale" do
      settings = Settings.toggle_stale(%Settings{})

      assert RunSummary.from_settings(settings) =~ ~r/\ARan selected tests:\n/
    end

    test "ran selected tests with filename patterns" do
      settings = Settings.with_filename_patterns(%Settings{}, ["p1"])

      assert RunSummary.from_settings(settings) =~ ~r/\ARan selected tests:\n/
    end

    test "ran selected tests with excluded tags" do
      settings = Settings.with_excludes(%Settings{}, ["tag1"])

      assert RunSummary.from_settings(settings) =~ ~r/\ARan selected tests:\n/
    end

    test "ran selected tests with included tags" do
      settings = Settings.with_includes(%Settings{}, ["tag1"])

      assert RunSummary.from_settings(settings) =~ ~r/\ARan selected tests:\n/
    end

    test "ran selected tests with only tags" do
      settings = Settings.with_only(%Settings{}, ["tag1"])

      assert RunSummary.from_settings(settings) =~ ~r/\ARan selected tests:\n/
    end
  end

  describe "summary details" do
    test "includes failed" do
      settings = Settings.toggle_failed(%Settings{})

      assert RunSummary.from_settings(settings) =~ "Failed tests"
    end

    test "includes stale" do
      settings = Settings.toggle_stale(%Settings{})

      assert RunSummary.from_settings(settings) =~ "Stale tests"
    end

    test "includes filename patterns" do
      settings = Settings.with_filename_patterns(%Settings{}, ["p1", "p2"])

      assert RunSummary.from_settings(settings) =~ ~s(Filename patterns: ["p1", "p2"])
    end

    test "includes max failures" do
      settings = Settings.with_max_failures(%Settings{}, "6")

      assert RunSummary.from_settings(settings) =~ "Max failures: 6"
    end

    test "includes repeat count" do
      settings = Settings.with_repeat_count(%Settings{}, "150")

      assert RunSummary.from_settings(settings) =~ "Repeat until failure: 150"
    end

    test "includes seed" do
      settings = Settings.with_seed(%Settings{}, "4242")

      assert RunSummary.from_settings(settings) =~ "Seed: 4242"
    end

    test "includes tag filters" do
      settings =
        %Settings{}
        |> Settings.with_excludes(["tag1", "tag2"])
        |> Settings.with_includes(["tag3", "tag4"])
        |> Settings.with_only(["tag5", "tag6"])

      summary = RunSummary.from_settings(settings)

      assert summary =~ ~s(Excluding tags: ["tag1", "tag2"])
      assert summary =~ ~s(Including tags: ["tag3", "tag4"])
      assert summary =~ ~s(Only tags: ["tag5", "tag6"])
    end

    test "includes tracing" do
      settings = Settings.toggle_tracing(%Settings{})

      assert RunSummary.from_settings(settings) =~ "Tracing: ON"
    end

    test "includes only relevant information with no extra blank lines" do
      settings =
        %Settings{}
        |> Settings.toggle_stale()
        |> Settings.toggle_tracing()
        |> Settings.with_only(["tag1", "tag2"])
        |> Settings.with_seed("4258")

      expected = """
      Ran selected tests:
      Stale tests
      Only tags: ["tag1", "tag2"]
      Seed: 4258
      Tracing: ON
      """

      assert RunSummary.from_settings(settings) == String.trim(expected)
    end

    test "lists every active setting in order" do
      settings =
        %Settings{}
        |> Settings.toggle_failed()
        |> Settings.toggle_stale()
        |> Settings.with_filename_patterns(["p1", "p2"])
        |> Settings.with_excludes(["tag1"])
        |> Settings.with_includes(["tag2"])
        |> Settings.with_only(["tag3"])
        |> Settings.with_max_failures("3")
        |> Settings.with_repeat_count("10")
        |> Settings.with_seed("4258")
        |> Settings.toggle_tracing()

      expected = """
      Ran selected tests:
      Failed tests
      Stale tests
      Filename patterns: ["p1", "p2"]
      Excluding tags: ["tag1"]
      Including tags: ["tag2"]
      Only tags: ["tag3"]
      Max failures: 3
      Repeat until failure: 10
      Seed: 4258
      Tracing: ON
      """

      assert RunSummary.from_settings(settings) == String.trim(expected)
    end
  end
end
