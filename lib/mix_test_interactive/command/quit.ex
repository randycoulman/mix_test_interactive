defmodule MixTestInteractive.Command.Quit do
  alias MixTestInteractive.Command

  use Command, command: "q", desc: "quit"

  @impl Command
  def run(_args, _config), do: :quit
end
