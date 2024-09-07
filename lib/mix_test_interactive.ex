defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """
  alias MixTestInteractive.CommandLineParser
  alias MixTestInteractive.InitialSupervisor
  alias MixTestInteractive.InteractiveMode
  alias MixTestInteractive.MainSupervisor
  alias MixTestInteractive.Settings

  @application :mix_test_interactive

  @doc """
  Start the interactive test runner.
  """
  def run(args \\ []) when is_list(args) do
    %Settings{} = settings = CommandLineParser.parse(args)

    {:ok, _} = Application.ensure_all_started(@application)
    {:ok, _supervisor} = DynamicSupervisor.start_child(InitialSupervisor, {MainSupervisor, settings: settings})

    loop()
  end

  defp loop do
    command = IO.gets("")
    InteractiveMode.process_command(command)
    loop()
  end
end
