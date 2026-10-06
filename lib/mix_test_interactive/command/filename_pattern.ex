defmodule MixTestInteractive.Command.FilenamePattern do
  @moduledoc false

  # Specify one or more filename patterns.
  #
  # Runs all tests that contain at least one of the filename patterns as a substring of their filename.

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
