defmodule MixTestInteractive.Command.ToggleFailed do
  @moduledoc false

  use MixTestInteractive.Command, command: "f", desc: "turn failed tests on/off"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def run([], settings) do
    {:ok, Settings.toggle_failed(settings)}
  end
end
