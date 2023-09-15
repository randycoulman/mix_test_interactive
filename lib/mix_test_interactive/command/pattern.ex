defmodule MixTestInteractive.Command.Pattern do
  @moduledoc """
  Specify one or more filename-matching patterns.

  Runs all tests that contain at least one of the patterns as a substring of their filename.

  If any pattern looks like a filename/line number pattern, then all of the patterns
  are passed on to `mix test` directly; no filtering is done.  This is because `mix test`
  only supports a single filename-with-line-number pattern at a time.
  """

  use MixTestInteractive.Command, command: "p", desc: "run only test files matching pattern(s)"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "p <patterns>"

  @impl Command
  def run(patterns, settings) do
    {:ok, Settings.only_patterns(settings, patterns)}
  end
end
