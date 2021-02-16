defmodule MixTestInteractive.Command.Stale do
  @moduledoc """
  Run only stale tests.

  Equivalent to `mix test --stale`.
  """

  alias MixTestInteractive.{Command, Config}

  use Command, command: "s", desc: "run only stale tests"

  @impl Command
  def applies?(%Config{stale?: false}), do: true
  def applies?(_config), do: false

  @impl Command
  def run(_args, config) do
    {:ok, Config.only_stale(config)}
  end
end
