defmodule MixTestInteractive.Command.Failed do
  @moduledoc """
  Run only failed tests.

  Equivalent to `mix test --failed`.
  """

  use MixTestInteractive.Command, command: "f", desc: "run only failed tests"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def applies?(%Settings{failed?: false}), do: true
  def applies?(_settings), do: false

  @impl Command
  def run(_args, settings) do
    {:ok, Settings.only_failed(settings)}
  end
end
