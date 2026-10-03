defmodule MixTestInteractive.FilenamePatternFilterTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.FilenamePatternFilter

  @abc "test/project/abc_test.exs"
  @bcd "test/project/bcd_test.exs"
  @cde "test/project/cde_test.exs"

  @files [@abc, @bcd, @cde]

  test "returns files matching a filename pattern" do
    matches = FilenamePatternFilter.matches(@files, "bc")

    assert matches == [@abc, @bcd]
  end

  test "returns empty list if no matches" do
    matches = FilenamePatternFilter.matches(@files, "xyz")

    assert matches == []
  end

  test "returns files matching at least one of multiple filename patterns" do
    matches = FilenamePatternFilter.matches(@files, ["ab", "de"])

    assert matches == [@abc, @cde]
  end

  test "returns multiple file with line number filename patterns" do
    patterns = ["some_test.exs:42", "other_test.exs:58"]
    matches = FilenamePatternFilter.matches(@files, patterns)

    assert matches == patterns
  end

  test "returns files with relative pathnames" do
    pattern = "./#{@abc}"
    matches = FilenamePatternFilter.matches(@files, pattern)

    assert matches == [@abc]
  end

  test "uses non-relative pathnames as normal filename patterns" do
    pattern = Path.expand("./#{@bcd}")
    matches = FilenamePatternFilter.matches(@files, pattern)
    assert matches == []
  end

  test "returns a mix of matching files, relative pathnames, and files with line numbers" do
    patterns = ["some_test.exs:42", "ab", "other_test.exs:58", "./#{@bcd}"]
    matches = FilenamePatternFilter.matches(@files, patterns)

    assert matches == [@abc, @bcd, "some_test.exs:42", "other_test.exs:58"]
  end
end
