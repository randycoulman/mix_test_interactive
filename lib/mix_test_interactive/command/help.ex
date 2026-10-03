defmodule MixTestInteractive.Command.Help do
  @moduledoc """
  Show detailed usage information.

  Lists all commands.
  """

  use MixTestInteractive.Command, command: "?", desc: "show help"

  alias MixTestInteractive.Command

  @impl Command
  def run([], _settings), do: :help
end
