defmodule MixTestInteractive.Command.RunTests do
  alias MixTestInteractive.Command

  use Command, command: "", desc: "trigger a test run"

  @impl Command
  def name, do: "Enter"

  @impl Command
  def run(_args, config), do: {:ok, config}
end
