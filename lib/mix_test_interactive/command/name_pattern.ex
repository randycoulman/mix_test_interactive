defmodule MixTestInteractive.Command.NamePattern do
  @moduledoc false
  use MixTestInteractive.Command, command: "n", desc: "set or clear the name pattern"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "n [<name pattern>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_name_pattern(settings)}
  end

  @impl Command
  def run([name_pattern], %Settings{} = settings) do
    {:ok, Settings.with_name_pattern(settings, name_pattern)}
  end
end
