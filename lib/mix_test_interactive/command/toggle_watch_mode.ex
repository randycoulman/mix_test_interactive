defmodule MixTestInteractive.Command.ToggleWatchMode do
  @moduledoc """
  Toggle file-watching mode on or off.

  When watch mode is on, `mix test.interactive` will re-run the
  current set of tests whenever a file changes.

  When it is off, tests must be run manually, either by changing
  using a command to change the configuration, or by using the
  `MixTestInteractive.Command.RunTests` command.
  """

  alias MixTestInteractive.{Command, Config}

  use Command, command: "w", desc: "turn watch mode on/off"

  @impl Command
  def run(_args, config) do
    {:no_run, Config.toggle_watch_mode(config)}
  end
end
