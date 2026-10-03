defmodule MixTestInteractive.Command.FilenamePattern do
  @moduledoc """
  Specify one or more filename patterns.

  Runs all tests that contain at least one of the filename patterns as a substring of their filename.

  If any filename pattern includes a line number, then all of the filename patterns
  are passed on to `mix test` directly; no filtering is done.  This is because `mix test`
  only supports a single filename with a line number at a time.
  """

  use MixTestInteractive.Command, command: "p", desc: "run only test files matching filename pattern(s)"

  alias MixTestInteractive.Command
  alias MixTestInteractive.Settings

  @impl Command
  def name, do: "p <filename patterns>"

  @impl Command
  def run(filename_patterns, settings) do
    {:ok, Settings.with_filename_patterns(settings, filename_patterns)}
  end
end
