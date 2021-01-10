defmodule MixTestInteractive.InteractiveMode do
  alias MixTestInteractive.{CommandProcessor, Runner}

  def start(config) do
    run_tests(config)
    loop(config)
  end

  defp loop(config) do
    command = IO.gets("")

    case CommandProcessor.call(command, config) do
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