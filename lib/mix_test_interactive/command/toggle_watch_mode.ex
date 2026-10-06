defmodule MixTestInteractive.Command.ToggleWatchMode do
  @moduledoc false

  use MixTestInteractive.Command, command: "w", desc: "turn watch mode on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run([], settings) do
    {:no_run, Settings.toggle_watch_mode(settings)}
  end
end
