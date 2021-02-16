defmodule MixTestInteractive.Command.Failed do
  @moduledoc """
  Run only failed tests.

  Equivalent to `mix test --failed`.
  """

  alias MixTestInteractive.{Command, Settings}

  use Command, command: "f", desc: "run only failed tests"

  @impl Command
  def applies?(%Settings{failed?: false}), do: true
  def applies?(_settings), do: false

  @impl Command
  def run(_args, settings) do
    {:ok, Settings.only_failed(settings)}
  end
end
