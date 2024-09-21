defmodule MixTestInteractive.Command.Include do
  @moduledoc """
  Specify or clear tags to include.

  Runs the tests excluding the given tags if provided. If not provided, the
  includes are cleared and the tests will run with any includes configured in
  your `ExUnit.configure/1` call (if any).
  """
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
