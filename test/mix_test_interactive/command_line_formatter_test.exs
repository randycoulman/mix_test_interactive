defmodule MixTestInteractive.CommandLineFormatterTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.CommandLineFormatter

  describe "formatting a command line with proper quoting" do
    test "formats simple commands without quoting" do
      assert CommandLineFormatter.call("mix", ["test", "--stale", "file.exs"]) ==
               ~s(mix test --stale file.exs)
    end

    test "double-quotes arguments with spaces" do
      assert CommandLineFormatter.call("mix", ["test", "file with spaces.txt"]) ==
               ~s(mix test "file with spaces.txt")
    end

    test "double-quotes arguments with special characters" do
      args = ["do", "eval", "Application.put_env(:elixir,:ansi_enabled,true)", ",", "test"]
      expected = ~s[mix do eval "Application.put_env(:elixir,:ansi_enabled,true)" , test]

      assert CommandLineFormatter.call("mix", args) == expected
    end

    test "single-quotes arguments containing only double quotes" do
      args = ["do", "eval", ~s[IO.puts("running tests!")], ",", "test"]
      expected = ~s[mix do eval 'IO.puts("running tests!")' , test]

      assert CommandLineFormatter.call("mix", args) == expected
    end

    test "double-quotes arguments with mixed single and double quotes" do
      args = ["do", "eval", ~s[IO.puts("I'm testing")], ",", "test"]
      expected = ~s[mix do eval 'IO.puts(\"I'\\''m testing\")' , test]

      assert CommandLineFormatter.call("mix", args) == expected
    end
  end
end
