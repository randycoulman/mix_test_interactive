defmodule MixTestInteractive.Command.Exclude do
  @moduledoc false
  use MixTestInteractive.Command, command: "x", desc: "set or clear excluded tags"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "x [<tags...>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_excludes(settings)}
  end

  @impl Command
  def run(tags, %Settings{} = settings) do
    {:ok, Settings.with_excludes(settings, tags)}
  end
end
