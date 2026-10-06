defmodule MixTestInteractive.Command.RunTests do
  @moduledoc false

  use MixTestInteractive.Command, command: "", desc: "trigger a test run"

  alias MixTestInteractive.Command

  @impl Command
  def name, do: "Enter"

  @impl Command
  def run([], settings), do: {:ok, settings}
end
