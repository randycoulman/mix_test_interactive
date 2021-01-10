defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """

  @spec run([String.t()]) :: no_return()
  def run(args \\ []) when is_list(args) do
    Mix.env(:test)
    :ok = Application.ensure_started(:mix_test_interactive)
    loop()
  end

  defp loop do
    cmd = IO.getn("")

    unless cmd == "q" do
      loop()
    end
  end
end
