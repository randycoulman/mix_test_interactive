defmodule MixTestInteractive.Command.Help do
  alias MixTestInteractive.Command

  use Command, command: "?", desc: "show help"

  @impl Command
  def run(_args, _config), do: :help
end
