defmodule MixTestInteractive.Command.Stale do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "s", desc: "run only stale tests"

  @impl Command
  def applies?(%Config{stale?: false}), do: true
  def applies?(_config), do: false

  @impl Command
  def run(_args, config) do
    {:ok, Config.only_stale(config)}
  end
end
