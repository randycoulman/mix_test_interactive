defmodule MixTestInteractive.Runner do
  @moduledoc false

  alias MixTestInteractive.Config

  @doc """
  Run tests using provided runner.
  """
  @spec run(Config.t()) :: :ok | {:error, term()}
  def run(config) do
    :ok = maybe_clear_terminal(config)
    IO.puts("\nRunning tests...")
    :ok = maybe_print_timestamp(config)
    config.runner.run(config)
  end

  defp maybe_clear_terminal(%{clear: false}), do: :ok
  defp maybe_clear_terminal(%{clear: true}), do: :ok = IO.puts(IO.ANSI.clear() <> IO.ANSI.home())

  defp maybe_print_timestamp(%{timestamp: false}), do: :ok

  defp maybe_print_timestamp(%{timestamp: true}) do
    :ok =
      DateTime.utc_now()
      |> DateTime.to_string()
      |> IO.puts()
  end
end
