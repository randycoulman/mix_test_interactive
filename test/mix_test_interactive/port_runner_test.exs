defmodule MixTestInteractive.PortRunnerTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.PortRunner

  describe "building a command" do
    test "builds a command to run mix test ANSI-enabled" do
      expected =
        "MIX_ENV=test mix do run -e " <>
          "'Application.put_env(:elixir, :ansi_enabled, true);', test"

      assert PortRunner.build_command() == expected
    end
  end
end
