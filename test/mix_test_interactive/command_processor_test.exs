defmodule MixTestInteractive.CommandProcessorTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.CommandProcessor
  alias MixTestInteractive.Settings

  defp process_command(command, settings \\ %Settings{}) do
    CommandProcessor.call(command, settings)
  end

  describe "commands" do
    test ":eof returns :quit" do
      assert :quit = process_command(:eof)
    end

    test "q returns :quit" do
      assert :quit = process_command("q")
    end

    test "Enter returns ok tuple" do
      settings = %Settings{}
      assert {:ok, ^settings} = process_command("", settings)
    end

    test "a runs all tests" do
      {:ok, settings} = process_command("s", %Settings{})
      expected = Settings.all_tests(settings)

      assert {:ok, ^expected} = process_command("a", settings)
    end

    test "d <seed> sets the test seed" do
      settings = %Settings{}
      expected = Settings.with_seed(settings, "4258")

      assert {:ok, ^expected} = process_command("d 4258", settings)
    end

    test "d with no seed clears the test seed" do
      {:ok, settings} = process_command("d 1234", %Settings{})
      expected = Settings.clear_seed(settings)

      assert {:ok, ^expected} = process_command("d", settings)
    end

    test "f runs only failed tests" do
      settings = %Settings{}
      expected = Settings.only_failed(settings)

      assert {:ok, ^expected} = process_command("f", settings)
    end

    test "i <tag...> includes the given tags" do
      settings = %Settings{}
      expected = Settings.with_includes(settings, ["tag1", "tag2"])

      assert {:ok, ^expected} = process_command("i tag1 tag2", settings)
    end

    test "i with no tags clears the includes" do
      {:ok, settings} = process_command("i tag1", %Settings{})
      expected = Settings.clear_includes(settings)

      assert {:ok, ^expected} = process_command("i", settings)
    end

    test "m <max> sets max-failures" do
      settings = %Settings{}
      expected = Settings.with_max_failures(settings, "4")

      assert {:ok, ^expected} = process_command("m 4", settings)
    end

    test "m with no seed clears max-failures" do
      {:ok, settings} = process_command("m 1", %Settings{})
      expected = Settings.clear_max_failures(settings)

      assert {:ok, ^expected} = process_command("m", settings)
    end

    test "o <tag...> runs with only the given tags" do
      settings = %Settings{}
      expected = Settings.with_only(settings, ["tag1", "tag2"])

      assert {:ok, ^expected} = process_command("o tag1 tag2", settings)
    end

    test "o with no tags clears the only" do
      {:ok, settings} = process_command("o tag1", %Settings{})
      expected = Settings.clear_only(settings)

      assert {:ok, ^expected} = process_command("o", settings)
    end

    test "p filters test files to those matching provided pattern" do
      settings = %Settings{}
      expected = Settings.only_patterns(settings, ["pattern"])

      assert {:ok, ^expected} = process_command("p pattern", settings)
    end

    test "p a second time replaces patterns with new ones" do
      settings = %Settings{}
      {:ok, first_config} = process_command("p first", %Settings{})
      expected = Settings.only_patterns(settings, ["second"])

      assert {:ok, ^expected} = process_command("p second", first_config)
    end

    test "r <count> sets the repeat until failure count" do
      settings = %Settings{}
      expected = Settings.with_repeat_count(settings, "4200")

      assert {:ok, ^expected} = process_command("r 4200", settings)
    end

    test "r with no count clears the repeat until failure count" do
      {:ok, settings} = process_command("r 1000", %Settings{})
      expected = Settings.clear_repeat_count(settings)

      assert {:ok, ^expected} = process_command("r", settings)
    end

    test "s runs only stale tests" do
      settings = %Settings{}
      expected = Settings.only_stale(settings)

      assert {:ok, ^expected} = process_command("s", settings)
    end

    test "t toggles tracing" do
      settings = %Settings{}
      expected = Settings.toggle_tracing(settings)

      assert {:ok, ^expected} = process_command("t", settings)
    end

    test "w toggles watch mode" do
      settings = %Settings{}
      expected = Settings.toggle_watch_mode(settings)

      assert {:no_run, ^expected} = process_command("w", settings)
    end

    test "x <tag...> excludes the given tags" do
      settings = %Settings{}
      expected = Settings.with_excludes(settings, ["tag1", "tag2"])

      assert {:ok, ^expected} = process_command("x tag1 tag2", settings)
    end

    test "x with no tags clears the excludes" do
      {:ok, settings} = process_command("x tag1", %Settings{})
      expected = Settings.clear_excludes(settings)

      assert {:ok, ^expected} = process_command("x", settings)
    end

    test "? returns :help" do
      settings = %Settings{}

      assert :help = process_command("?", settings)
    end

    test "trims whitespace from commands" do
      assert :quit = process_command("\t  q   \n   \t")
    end
  end

  describe "usage information" do
    test "shows relevant commands when running all tests" do
      settings = %Settings{}

      assert_commands(settings, ["p <patterns>", "s", "f"], ~w(a))
    end

    test "shows relevant commands when filtering by pattern" do
      settings =
        Settings.only_patterns(%Settings{}, ["pattern"])

      assert_commands(settings, ["p <patterns>", "s", "f", "a"], ~w(p))
    end

    test "shows relevant commands when running failed tests" do
      settings =
        Settings.only_failed(%Settings{})

      assert_commands(settings, ["p <patterns>", "s", "a"], ~w(f))
    end

    test "shows relevant commands when running stale tests" do
      settings =
        Settings.only_stale(%Settings{})

      assert_commands(settings, ["p <patterns>", "f", "a"], ~w(s))
    end

    defp assert_commands(settings, included, excluded) do
      included = included ++ ~w(Enter ? q)
      usage = CommandProcessor.usage(settings)

      assert contains?(usage, "Usage:\n")

      for command <- included do
        assert contains?(usage, command)
      end

      for command <- excluded do
        refute contains?(usage, command)
      end
    end

    defp contains?([], _string), do: false

    defp contains?([h | t], string) do
      contains?(h, string) || contains?(t, string)
    end

    defp contains?(usage, string) when is_binary(usage) do
      usage == string
    end
  end
end
