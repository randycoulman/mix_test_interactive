defmodule MixTestInteractive.Command.Only do
  @moduledoc false
  use MixTestInteractive.Command, command: "o", desc: "set or clear only tags"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "o [<tags...>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_only(settings)}
  end

  @impl Command
  def run(tags, %Settings{} = settings) do
    {:ok, Settings.with_only(settings, tags)}
  end
end
