defmodule MixTestInteractive.Command.Exclude do
  @moduledoc """
  Specify or clear tags to exclude.

  Runs the tests excluding the given tags if provided. If not provided, the
  excludes are cleared and the tests will run with any excludes configured in
  your `ExUnit.configure/1` call (if any).
  """
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
