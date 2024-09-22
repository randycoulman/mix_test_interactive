defmodule MixTestInteractive.RunSummaryTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.RunSummary
  alias MixTestInteractive.Settings

  describe "summarizing a test run" do
    test "ran all tests" do
      settings = %Settings{}

      assert RunSummary.from_settings(settings) == "Ran all tests"
    end

    test "ran failed tests" do
      settings = Settings.only_failed(%Settings{})

      assert RunSummary.from_settings(settings) == "Ran only failed tests"
    end

    test "ran stale tests" do
      settings = Settings.only_stale(%Settings{})

      assert RunSummary.from_settings(settings) == "Ran only stale tests"
    end

    test "ran specific patterns" do
      settings =
        Settings.only_patterns(%Settings{}, ["p1", "p2"])

      assert RunSummary.from_settings(settings) == "Ran all test files matching p1, p2"
    end

    test "appends max failures" do
      settings = Settings.with_max_failures(%Settings{}, "6")

      assert RunSummary.from_settings(settings) =~ "Max failures: 6"
    end

    test "appends repeat count" do
      settings = Settings.with_repeat_count(%Settings{}, "150")

      assert RunSummary.from_settings(settings) =~ "Repeat until failure: 150"
    end

    test "appends seed" do
      settings = Settings.with_seed(%Settings{}, "4242")

      assert RunSummary.from_settings(settings) =~ "Seed: 4242"
    end

    test "appends tag filters" do
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

    test "appends tracing" do
      settings = Settings.toggle_tracing(%Settings{})

      assert RunSummary.from_settings(settings) =~ "Tracing: ON"
    end

    test "includes only relevant information with no extra blank lines" do
      settings =
        %Settings{}
        |> Settings.only_stale()
        |> Settings.toggle_tracing()
        |> Settings.with_only(["tag1", "tag2"])
        |> Settings.with_seed("4258")

      expected = """
      Ran only stale tests
      Only tags: ["tag1", "tag2"]
      Seed: 4258
      Tracing: ON
      """

      assert RunSummary.from_settings(settings) == String.trim(expected)
    end
  end
end
