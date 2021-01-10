defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """

  alias MixTestInteractive.{Config, InteractiveMode}

  @spec run([String.t()]) :: :ok
  def run(args \\ []) when is_list(args) do
    Mix.env(:test)
    config = Config.new(args)
    :ok = Application.ensure_started(:mix_test_interactive)

    InteractiveMode.start(config)
  end
end
