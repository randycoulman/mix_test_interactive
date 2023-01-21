defmodule MixTestInteractive.Command.Tags do
  @moduledoc """
  Specify one or more tags.

  Runs all tests that are tagged with at least one of the given tags.

  Equivalent to `mix test --only <tag>`.
  """

  alias MixTestInteractive.{Command, Settings}

  use Command, command: "t", desc: "run only tests matching tag(s)"

  @impl Command
  def name, do: "t <tags>"

  @impl Command
  def run(tags, settings) do
    {:ok, Settings.only_tags(settings, tags)}
  end
end
