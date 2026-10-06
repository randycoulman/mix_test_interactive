defmodule MixTestInteractive.Command.ToggleStale do
  @moduledoc false

  use MixTestInteractive.Command, command: "s", desc: "turn stale tests on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run([], settings) do
    {:ok, Settings.toggle_stale(settings)}
  end
end
