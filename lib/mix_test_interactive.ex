defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """

  @spec run([String.t()]) :: :ok
  def run(args \\ []) when is_list(args) do
    Mix.env(:test)
    :ok = Application.ensure_started(:mix_test_interactive)
    IO.puts("Interactive mode goes here!")
    :ok
  end
end
