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

    test "p filters files to provided list" do
      config = Config.new()
      files = ["file1", "file2"]
      expected = Config.only_files(config, files)

      assert {:ok, ^expected} = process_command("p file1 file2", config)
    end

    test "c clears file filters" do
      {:ok, config} = process_command("p file", Config.new())
      expected = Config.clear_filters(config)

      assert {:ok, ^expected} = process_command("c", config)
    end

    test "s runs only stale files" do
      config = Config.new()
      expected = Config.only_stale(config)

      assert {:ok, ^expected} = process_command("s", config)
    end

    test "f runs only failed files" do
      config = Config.new()
      expected = Config.only_failed(config)

      assert {:ok, ^expected} = process_command("f", config)
    end

    test "a runs all files" do
      {:ok, config} = process_command("s", Config.new())
      expected = Config.clear_flags(config)

      assert {:ok, ^expected} = process_command("a", config)
    end

    test "trims whitespace from commands" do
      assert :quit = process_command("\t  q   \n   \t")
    end
  end

  describe "usage information" do
    test "usage describes all commands" do
      usage = CommandProcessor.usage()
      assert usage =~ ~r/^Usage/
      assert usage =~ ~r/^› p/m
      assert usage =~ ~r/^› c/m
      assert usage =~ ~r/^› s/m
      assert usage =~ ~r/^› f/m
      assert usage =~ ~r/^› a/m
      assert usage =~ ~r/^› Enter/m
      assert usage =~ ~r/^› q/m
    end
  end
end
