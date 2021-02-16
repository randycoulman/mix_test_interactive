defmodule MixTestInteractive.TestFiles do
  @moduledoc false

  @doc """
  List available test files

  Respects the configured `:test_paths` and `:test_pattern` settings.
  Used internally to filter test files by pattern on each test run.
  That way, any new files that match an existing pattern will be picked
  up immediately.
  """
  @spec list() :: [String.t()]
  def list() do
    config = Mix.Project.config()
    paths = config[:test_paths] || ["test"]
    pattern = config[:test_pattern] || "*_test.exs"

    Mix.Utils.extract_files(paths, pattern)
  end
end
