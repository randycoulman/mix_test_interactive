defmodule MixTestInteractive.Command.Help do
  @moduledoc """
  Show detailed usage information.

  Lists all commands applicable to the current context.
  """

  use MixTestInteractive.Command, command: "?", desc: "show help"

  alias MixTestInteractive.Command

  @impl Command
  def run(_args, _settings), do: :help
end
