defmodule MixTestInteractive do
  @moduledoc """
  Interactively run your Elixir project's tests.
  """

  alias MixTestInteractive.{CommandProcessor, Config, Runner}

  @spec run([String.t()]) :: :ok
  def run(args \\ []) when is_list(args) do
    Mix.env(:test)
    config = Config.new(args)
    :ok = Application.ensure_started(:mix_test_interactive)
    run_tests(config)
    loop(config)
  end

  defp loop(config) do
    command = IO.gets("")

    case CommandProcessor.process_command(command, config) do
      {:ok, new_config} ->
        run_tests(new_config)
        loop(new_config)

      :unknown ->
        loop(config)

      :quit ->
        :ok
    end
  end

  defp run_tests(config) do
    Runner.run(config)
    show_usage()
  end

  defp show_usage() do
    IO.puts("")
    IO.puts(CommandProcessor.usage())
  end
end
