defmodule MixTestInteractive.Command.Stale do
  @moduledoc """
  Run only stale tests.

  Equivalent to `mix test --stale`.
  """

  use MixTestInteractive.Command, command: "s", desc: "run only stale tests"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def applies?(%Settings{stale?: false}), do: true
  def applies?(_settings), do: false

  @impl Command
  def run(_args, settings) do
    {:ok, Settings.only_stale(settings)}
  end
end
