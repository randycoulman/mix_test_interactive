defmodule MixTestInteractive.Command.ToggleWatchMode do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "w", desc: "turn watch mode on/off"

  @impl Command
  def run(_args, config) do
    {:no_run, Config.toggle_watch_mode(config)}
  end
end
