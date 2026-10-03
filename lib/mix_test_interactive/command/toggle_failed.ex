defmodule MixTestInteractive.Command.ToggleFailed do
  @moduledoc """
  Toggle running of only failed tests on or off.

  When on, runs only previously-failed tests.

  Equivalent to `mix test --failed`.
  """

  use MixTestInteractive.Command, command: "f", desc: "turn failed tests on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run([], settings) do
    {:ok, Settings.toggle_failed(settings)}
  end
end
