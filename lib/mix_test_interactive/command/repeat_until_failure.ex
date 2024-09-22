defmodule MixTestInteractive.Command.RepeatUntilFailure do
  @moduledoc """
  Specify or clear the number of repetitions for running until failure.

  Runs the tests repeatedly until failure or until the specified number of runs.
  If not provided, the count is cleared and the tests will run just once as
  usual.

  Corresponds to `mix test --repeat-until-failure <count>`.

  This option is only available in `mix test` in Elixir 1.17.0 and later.
  """
  use MixTestInteractive.Command, command: "r", desc: "set or clear the repeat-until-failure count"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "r [<count>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_repeat_count(settings)}
  end

  @impl Command
  def run([count], %Settings{} = settings) do
    {:ok, Settings.with_repeat_count(settings, count)}
  end
end
