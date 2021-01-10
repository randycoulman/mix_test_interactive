defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """

  alias MixTestInteractive.{Config, Runner}

  @spec run([String.t()]) :: no_return()
  def run(args \\ []) when is_list(args) do
    Mix.env(:test)
    config = Config.new(args)
    :ok = Application.ensure_started(:mix_test_interactive)
    loop(config)
  end

  defp loop(config) do
    Runner.run(config)
    cmd = IO.getn("")

    unless cmd == "q" do
      loop(config)
    end
  end
end
