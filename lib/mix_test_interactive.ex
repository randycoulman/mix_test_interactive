defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """
  alias MixTestInteractive.CommandLineParser
  alias MixTestInteractive.InitialSupervisor
  alias MixTestInteractive.InteractiveMode
  alias MixTestInteractive.MainSupervisor

  @application :mix_test_interactive

  @doc """
  Start the interactive test runner.
  """
  def run(args \\ []) when is_list(args) do
    case CommandLineParser.parse(args) do
      {:ok, %{config: config, settings: settings}} ->
        {:ok, _apps} = Application.ensure_all_started(@application)

        {:ok, _supervisor} =
          DynamicSupervisor.start_child(InitialSupervisor, {MainSupervisor, config: config, settings: settings})

        loop()

      {:error, error} ->
        IO.puts(:standard_error, Exception.message(error))
        IO.puts("")
        IO.puts(CommandLineParser.usage_message())
    end
  end

  defp loop do
    command = IO.gets("")
    InteractiveMode.process_command(command)
    loop()
  end
end
