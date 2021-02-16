defmodule MixTestInteractive.Command.Help do
  @moduledoc """
  Show detailed usage information.

  Lists all commands applicable to the current context.
  """

  alias MixTestInteractive.Command

  use Command, command: "?", desc: "show help"

  @impl Command
  def run(_args, _config), do: :help
end
