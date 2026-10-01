defmodule MixTestInteractive.Command.ToggleFailed do
  @moduledoc """
  Toggle running of only failed tests on or off.

  Runs only previously-failed tests when on; otherwise runs all tests.

  Equivalent to `mix test --failed`.
  """

  use MixTestInteractive.Command, command: "f", desc: "turn failed tests on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run(_args, settings) do
    {:ok, Settings.toggle_failed(settings)}
  end
end
