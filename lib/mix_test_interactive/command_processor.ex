defmodule MixTestInteractive.CommandProcessor do
  @moduledoc false

  alias MixTestInteractive.Config

  @spec process_command(String.t() | :eof, Config.t()) :: {:ok, Config.t()} | :unknown | :quit

  def process_command(:eof, _config), do: :quit

  def process_command(command, config) when is_binary(command) do
    command
    |> String.trim()
    |> do_process_command(config)
  end

  def usage do
    """
    Usage
    › Press Enter to trigger a test run.
    › Press q to quit.
    """
  end

  defp do_process_command("q", _config), do: :quit
  defp do_process_command("", config), do: {:ok, config}
  defp do_process_command(_unknown_command, _config), do: :unknown
end
