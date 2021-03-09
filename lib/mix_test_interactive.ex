defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """

  alias MixTestInteractive.InteractiveMode

  @doc """
  Start the interactive test runner.
  """
  @spec run([String.t()]) :: no_return()
  def(run(args \\ []) when is_list(args)) do
    Mix.env(:test)
    {:ok, _} = Application.ensure_all_started(:mix_test_interactive)

    InteractiveMode.command_line_arguments(args)
    loop()
  end

  defp loop do
    command = IO.gets("")
    InteractiveMode.process_command(command)
    loop()
  end
end
