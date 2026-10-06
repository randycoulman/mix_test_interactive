defmodule MixTestInteractive.Command.Quit do
  @moduledoc false

  use MixTestInteractive.Command, command: "q", desc: "quit"

  alias MixTestInteractive.Command

  @impl Command
  def run([], _settings), do: :quit
end
