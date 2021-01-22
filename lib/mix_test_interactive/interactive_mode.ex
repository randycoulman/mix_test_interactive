defmodule MixTestInteractive.InteractiveMode do
  alias MixTestInteractive.{CommandProcessor, Config, ConfigStore, Runner}

  def start(config) do
    ConfigStore.store(config)
    run_tests(config)
    loop(config)
  end

  def run_tests(config) do
    Runner.run(config)
    show_summary(config)
    show_usage_prompt()
  end

  defp loop(config) do
    command = IO.gets("")

    case CommandProcessor.call(command, config) do
      {:ok, new_config} ->
        ConfigStore.store(new_config)
        run_tests(new_config)
        loop(new_config)

      :help ->
        show_help(config)
        loop(config)

      :unknown ->
        loop(config)

      :quit ->
        :ok
    end
  end

  defp show_summary(config) do
    IO.puts("")

    config
    |> Config.summary()
    |> IO.puts()
  end

  defp show_usage_prompt() do
    IO.puts("")

    [:bright, "Usage: ?", :normal, " to show more"]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp show_help(config) do
    IO.puts("")

    config
    |> CommandProcessor.usage()
    |> IO.puts()
  end
end
