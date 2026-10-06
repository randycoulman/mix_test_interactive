defmodule MixTestInteractive.Command.Seed do
  @moduledoc false
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
