defmodule MixTestInteractive.Command.ToggleStale do
  @moduledoc """
  Toggle running of only stale tests on or off.

  When on, runs only stale tests (those affected by the latest file changes).

  Equivalent to `mix test --stale`.
  """

  use MixTestInteractive.Command, command: "s", desc: "turn stale tests on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run([], settings) do
    {:ok, Settings.toggle_stale(settings)}
  end
end
