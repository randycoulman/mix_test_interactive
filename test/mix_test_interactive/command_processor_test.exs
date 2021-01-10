defmodule MixTestInteractive.CommandProcessorTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.{CommandProcessor, Config}

  defp process_command(command, config \\ Config.new([])) do
    CommandProcessor.process_command(command, config)
  end

  describe "commands" do
    test "returns :quit on :eof" do
      assert :quit = process_command(:eof)
    end

    test "returns :quit on q command" do
      assert :quit = process_command("q")
    end

    test "returns ok tuple on Enter" do
      config = Config.new([])
      assert {:ok, ^config} = process_command("", config)
    end

    test "trims whitespace from commands" do
      assert :quit = process_command("\t  q   \n   \t")
    end
  end

  describe "usage information" do
    test "usage describes all commands" do
      expected = """
      Usage
      › Press Enter to trigger a test run.
      › Press q to quit.
      """

      assert CommandProcessor.usage() == expected
    end
  end
end
