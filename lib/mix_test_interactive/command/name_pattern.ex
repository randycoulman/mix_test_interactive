defmodule MixTestInteractive.Command.NamePattern do
  @moduledoc """
  Specify or clear the name pattern for test runs.

  Runs only the tests whose names match the given regular expression if
  provided. The words of the name pattern are joined with single spaces, so the
  name pattern doesn't need to be quoted. If not provided, the name pattern is
  cleared and tests run regardless of their names.

  Corresponds to `mix test --name-pattern <name pattern>` (Elixir 1.19.0 and later).
  """
  use MixTestInteractive.Command, command: "n", desc: "set or clear the name pattern"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "n [<name pattern>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_name_pattern(settings)}
  end

  @impl Command
  def run(words, %Settings{} = settings) do
    {:ok, Settings.with_name_pattern(settings, Enum.join(words, " "))}
  end
end
