defmodule MixTestInteractive.Command.Seed do
  @moduledoc """
  Specify or clear the random number seed for test runs.

  Runs the tests with the given seed if provided. If not provided, the seed is
  cleared and the tests will run with a random seed as usual.
  """
  use MixTestInteractive.Command, command: "d", desc: "set or clear the test seed"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "d [<seed>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_seed(settings)}
  end

  @impl Command
  def run([seed], %Settings{} = settings) do
    {:ok, Settings.with_seed(settings, seed)}
  end
end
