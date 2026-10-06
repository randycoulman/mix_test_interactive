defmodule MixTestInteractive.Command.Include do
  @moduledoc false
  use MixTestInteractive.Command, command: "i", desc: "set or clear included tags"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "i [<tags...>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_includes(settings)}
  end

  @impl Command
  def run(tags, %Settings{} = settings) do
    {:ok, Settings.with_includes(settings, tags)}
  end
end
