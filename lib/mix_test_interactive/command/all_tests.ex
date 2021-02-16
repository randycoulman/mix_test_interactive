defmodule MixTestInteractive.Command.AllTests do
  @moduledoc """
  Run all tests, removing any flags or filters.
  """

  alias MixTestInteractive.{Command, Config}

  use Command, command: "a", desc: "run all tests"

  @impl Command
  def applies?(%Config{failed?: true}), do: true
  def applies?(%Config{patterns: [_h | _t]}), do: true
  def applies?(%Config{stale?: true}), do: true
  def applies?(_config), do: false

  @impl Command
  def run(_args, config) do
    {:ok, Config.all_tests(config)}
  end
end
