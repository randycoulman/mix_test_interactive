defmodule MixTestInteractive.Command.Pattern do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "p", desc: "run only test files matching pattern(s)"

  @impl Command
  def name, do: "p <patterns>"

  @impl Command
  def run(patterns, config) do
    {:ok, Config.only_patterns(config, patterns)}
  end
end
