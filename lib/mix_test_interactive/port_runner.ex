defmodule MixTestInteractive.PortRunner do
  @moduledoc """
  Run the tasks in a new OS process via ports
  """

  @doc """
  Run tests.
  """
  def run() do
    command = build_command()

    case :os.type() do
      {:win32, _} ->
        System.cmd("cmd", ["/C", "set MIX_ENV=test&& mix test"], into: IO.stream(:stdio, :line))

      _ ->
        Path.join(:code.priv_dir(:mix_test_interactive), "zombie_killer")
        |> System.cmd(["sh", "-c", command], into: IO.stream(:stdio, :line))
    end

    :ok
  end

  @doc """
  Build a shell command that runs mix test.

  Colour is forced on- normally Elixir would not print ANSI colours while
  running inside a port.
  """
  def build_command() do
    ansi = "run -e 'Application.put_env(:elixir, :ansi_enabled, true);'"

    ["mix", "do", ansi <> ",", "test"]
    |> Enum.filter(& &1)
    |> Enum.join(" ")
    |> (fn command -> "MIX_ENV=test #{command}" end).()
    |> String.trim()
  end
end
