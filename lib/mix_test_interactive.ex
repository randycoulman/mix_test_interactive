defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """

  alias MixTestInteractive.{Config, InteractiveMode}

  @spec run([String.t()]) :: :ok
  def run(args \\ []) when is_list(args) do
    Mix.env(:test)
    {:ok, _} = Application.ensure_all_started(:mix_test_interactive)

    config = Config.new(args)

    InteractiveMode.start(config)
  end
end
