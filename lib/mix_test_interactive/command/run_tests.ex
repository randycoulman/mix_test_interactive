defmodule MixTestInteractive.Command.RunTests do
  @moduledoc """
  Run all tests matching the current flags and filter settings.
  """

  use MixTestInteractive.Command, command: "", desc: "trigger a test run"

  alias MixTestInteractive.Command

  @impl Command
  def name, do: "Enter"

  @impl Command
  def run(_args, settings), do: {:ok, settings}
end
