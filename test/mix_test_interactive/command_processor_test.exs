defmodule MixTestInteractive.CommandProcessorTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.{CommandProcessor, Config}

  defp process_command(command) do
    config = Config.new([])
    CommandProcessor.process_command(command, config)
  end

  test "returns :quit on :eof" do
    assert :quit = process_command(:eof)
  end

  test "returns :quit for q command" do
    assert :quit = process_command("q")
  end

  test "trims whitespace from commands" do
    assert :quit = process_command("\t  q   \n   \t")
  end
end
