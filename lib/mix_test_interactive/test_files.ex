defmodule MixTestInteractive.TestFiles do
  def list() do
    config = Mix.Project.config()
    paths = config[:test_paths] || ["test"]
    pattern = config[:test_pattern] || "*_test.exs"

    Mix.Utils.extract_files(paths, pattern)
  end
end
