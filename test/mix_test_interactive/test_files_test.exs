defmodule MixTestInteractive.TestFilesTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.TestFiles

  test "returns all test files for current project" do
    files = TestFiles.list()
    this_file = Path.relative_to_cwd(__ENV__.file)

    assert this_file in files
  end
end
