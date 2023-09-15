defmodule MixTestInteractive.Command.AllTests do
  @moduledoc """
  Run all tests, removing any flags or filters.
  """

  use MixTestInteractive.Command, command: "a", desc: "run all tests"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def applies?(%Settings{failed?: true}), do: true
  def applies?(%Settings{patterns: [_h | _t]}), do: true
  def applies?(%Settings{stale?: true}), do: true
  def applies?(_settings), do: false

  @impl Command
  def run(_args, settings) do
    {:ok, Settings.all_tests(settings)}
  end
end
