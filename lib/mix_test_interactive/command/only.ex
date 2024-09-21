defmodule MixTestInteractive.Command.Only do
  @moduledoc """
  Specify or clear the only tags to run.

  Runs the tests with only the given tags if provided. If not provided, the list
  of only tags is cleared and the tests will run with any only configured in
  your `ExUnit.configure/1` call (if any).
  """
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
