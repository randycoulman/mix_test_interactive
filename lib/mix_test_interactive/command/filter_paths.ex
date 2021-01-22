defmodule MixTestInteractive.Command.FilterPaths do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "p", desc: "run only the specified test files"

  @impl Command
  def applies?(%Config{files: []}), do: true
  def applies?(_config), do: false

  @impl Command
  def name, do: "p <files>"

  @impl Command
  def run(files, config) do
    {:ok, Config.only_files(config, files)}
  end
end
