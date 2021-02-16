defmodule MixTestInteractive.Command.Quit do
  @moduledoc """
  Exit mix test.interactive.
  """

  alias MixTestInteractive.Command

  use Command, command: "q", desc: "quit"

  @impl Command
  def run(_args, _settings), do: :quit
end
