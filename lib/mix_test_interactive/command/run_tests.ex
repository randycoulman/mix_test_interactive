defmodule MixTestInteractive.Command.RunTests do
  @moduledoc """
  Run all tests matching the current flags and filter settings.
  """

  alias MixTestInteractive.Command

  use Command, command: "", desc: "trigger a test run"

  @impl Command
  def name, do: "Enter"

  @impl Command
  def run(_args, config), do: {:ok, config}
end
