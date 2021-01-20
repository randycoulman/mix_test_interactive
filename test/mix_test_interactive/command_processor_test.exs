defmodule MixTestInteractive.CommandProcessorTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.{CommandProcessor, Config}

  defp process_command(command, config \\ Config.new([])) do
    CommandProcessor.call(command, config)
  end

  describe "commands" do
    test ":eof returns :quit" do
      assert :quit = process_command(:eof)
    end

    test "q returns :quit" do
      assert :quit = process_command("q")
    end

    test "Enter returns ok tuple" do
      config = Config.new()
      assert {:ok, ^config} = process_command("", config)
    end

    test "p filters test files to provided list" do
      config = Config.new()
      files = ["file1", "file2"]
      expected = Config.only_files(config, files)

      assert {:ok, ^expected} = process_command("p file1 file2", config)
    end

    test "s runs only stale tests" do
      config = Config.new()
      expected = Config.only_stale(config)

      assert {:ok, ^expected} = process_command("s", config)
    end

    test "f runs only failed tests" do
      config = Config.new()
      expected = Config.only_failed(config)

      assert {:ok, ^expected} = process_command("f", config)
    end

    test "a runs all tests" do
      {:ok, config} = process_command("s", Config.new())
      expected = Config.all_tests(config)

      assert {:ok, ^expected} = process_command("a", config)
    end

    test "trims whitespace from commands" do
      assert :quit = process_command("\t  q   \n   \t")
    end
  end

  describe "usage information" do
    test "shows relevant commands when running all tests" do
      config = Config.new()

      assert_commands(config, ~w(p s f Enter q), ~w(a))
    end

    test "shows relevant commands when running specific files" do
      config =
        Config.new()
        |> Config.only_files(["file"])

      assert_commands(config, ~w(s f a Enter q), ~w(p))
    end

    test "shows relevant commands when running failed tests" do
      config =
        Config.new()
        |> Config.only_failed()

      assert_commands(config, ~w(p s a Enter q), ~w(f))
    end

    test "shows relevant commands when running stale tests" do
      config =
        Config.new()
        |> Config.only_stale()

      assert_commands(config, ~w(p f a Enter q), ~w(s))
    end

    defp assert_commands(config, included, excluded) do
      usage = CommandProcessor.usage(config)

      assert usage =~ ~r/^Usage/

      for command <- included do
        assert usage =~ ~r/^› #{command}/m
      end

      for command <- excluded do
        refute usage =~ ~r/^› #{command}/m
      end
    end
  end
end
