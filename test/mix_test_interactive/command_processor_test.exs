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

    test "p restricts files to provided list" do
      config = Config.new()
      files = ["file1", "file2"]
      expected = Config.only_files(config, files)

      assert {:ok, ^expected} = process_command("p file1 file2")
    end

    test "c clears file restrictions" do
      config = Config.new() |> Config.only_files("file")
      expected = Config.all_files(config)

      assert {:ok, ^expected} = process_command("c")
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
      assert usage =~ ~r/^› Enter/m
      assert usage =~ ~r/^› q/m
    end
  end
end
