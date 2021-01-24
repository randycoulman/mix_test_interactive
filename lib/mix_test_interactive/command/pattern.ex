defmodule MixTestInteractive.Command.Pattern do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "p", desc: "run only test files matching pattern(s)"

  @impl Command
  def applies?(%Config{patterns: []}), do: true
  def applies?(_config), do: false

  @impl Command
  def name, do: "p <patterns>"

  @impl Command
  def run(patterns, config) do
    {:ok, Config.only_patterns(config, patterns)}
  end
end
