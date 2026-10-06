defmodule MixTestInteractive.Command.ToggleTracing do
  @moduledoc false

  use MixTestInteractive.Command, command: "t", desc: "turn test tracing on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run([], settings) do
    {:ok, Settings.toggle_tracing(settings)}
  end
end
