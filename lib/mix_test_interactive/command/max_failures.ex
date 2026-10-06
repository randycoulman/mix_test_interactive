defmodule MixTestInteractive.Command.MaxFailures do
  @moduledoc false
  use MixTestInteractive.Command, command: "m", desc: "set or clear the maximum number of failures"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "m [<max>]"

  @impl Command
  def run([], %Settings{} = settings) do
    {:ok, Settings.clear_max_failures(settings)}
  end

  @impl Command
  def run([max], %Settings{} = settings) do
    {:ok, Settings.with_max_failures(settings, max)}
  end
end
