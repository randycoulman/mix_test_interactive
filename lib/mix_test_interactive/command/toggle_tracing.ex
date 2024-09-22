defmodule MixTestInteractive.Command.ToggleTracing do
  @moduledoc """
  Toggle test tracing on or off.

  Runs the tests in trace mode when tracing is on and normally when off.

  Corresponds to `mix test --trace`.
  """

  use MixTestInteractive.Command, command: "t", desc: "turn test tracing on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run(_args, settings) do
    {:ok, Settings.toggle_tracing(settings)}
  end
end
