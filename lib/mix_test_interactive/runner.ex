defmodule MixTestInteractive.Runner do
  @moduledoc """
  Runs tests based on current configuration.

  Also responsible for optionally clearing the terminal and printing the current time.
  """

  alias MixTestInteractive.{Config, Settings}

  @doc """
  Run tests using configured runner.
  """
  @spec run(Config.t(), Settings.t()) :: :ok | {:error, term()}
  def run(config, settings) do
    :ok = maybe_clear_terminal(config)
    IO.puts("\nRunning tests...")
    :ok = maybe_print_timestamp(config)
    config.runner.run(config, settings)
  end

  defp maybe_clear_terminal(%{clear?: false}), do: :ok
  defp maybe_clear_terminal(%{clear?: true}), do: :ok = IO.puts(IO.ANSI.clear() <> IO.ANSI.home())

  defp maybe_print_timestamp(%{show_timestamp?: false}), do: :ok

  defp maybe_print_timestamp(%{show_timestamp?: true}) do
    :ok =
      DateTime.utc_now()
      |> DateTime.to_string()
      |> IO.puts()
  end
end
