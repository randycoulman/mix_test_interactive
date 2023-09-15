defmodule MixTestInteractive.Command.Quit do
  @moduledoc """
  Exit mix test.interactive.
  """

  use MixTestInteractive.Command, command: "q", desc: "quit"

  alias MixTestInteractive.Command

  @impl Command
  def run(_args, _settings), do: :quit
end
