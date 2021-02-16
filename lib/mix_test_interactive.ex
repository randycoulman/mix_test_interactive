defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """

  alias MixTestInteractive.InteractiveMode

  @doc """
  Start the interactive test runner.
  """
  @spec run([String.t()]) :: :ok
  def run(args \\ []) when is_list(args) do
    Mix.env(:test)
    {:ok, _} = Application.ensure_all_started(:mix_test_interactive)

    InteractiveMode.initialize(args)
    loop()
  end

  defp loop do
    command = IO.gets("")

    case InteractiveMode.process_command(command) do
      :quit -> :ok
      :ok -> loop()
    end
  end
end
