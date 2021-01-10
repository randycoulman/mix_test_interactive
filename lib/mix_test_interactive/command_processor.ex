defmodule MixTestInteractive.CommandProcessor do
  @moduledoc false

  alias MixTestInteractive.Config

  @spec call(String.t() | :eof, Config.t()) :: {:ok, Config.t()} | :unknown | :quit

  def call(:eof, _config), do: :quit

  def call(command, config) when is_binary(command) do
    command
    |> String.trim()
    |> process_command(config)
  end

  def usage do
    """
    Usage
    › Press Enter to trigger a test run.
    › Press q to quit.
    """
  end

  defp process_command("q", _config), do: :quit
  defp process_command("", config), do: {:ok, config}
  defp process_command(_unknown_command, _config), do: :unknown
end
