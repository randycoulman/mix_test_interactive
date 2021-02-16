defmodule MixTestInteractive.Command.Failed do
  @moduledoc """
  Run only failed tests.

  Equivalent to `mix test --failed`.
  """

  alias MixTestInteractive.{Command, Config}

  use Command, command: "f", desc: "run only failed tests"

  @impl Command
  def applies?(%Config{failed?: false}), do: true
  def applies?(_config), do: false

  @impl Command
  def run(_args, config) do
    {:ok, Config.only_failed(config)}
  end
end
