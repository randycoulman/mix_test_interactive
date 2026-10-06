defmodule MixTestInteractive.Command.RepeatUntilFailure do
  @moduledoc false
  use MixTestInteractive.Command, command: "r", desc: "set or clear the repeat-until-failure count"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "r [<count>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_repeat_count(settings)}
  end

  @impl Command
  def run([count], %Settings{} = settings) do
    {:ok, Settings.with_repeat_count(settings, count)}
  end
end
