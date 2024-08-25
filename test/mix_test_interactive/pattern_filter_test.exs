defmodule MixTestInteractive.PatternFilterTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.PatternFilter

  @abc "test/project/abc_test.exs"
  @bcd "test/project/bcd_test.exs"
  @cde "test/project/cde_test.exs"

  @files [@abc, @bcd, @cde]

  test "returns files matching a pattern" do
    matches = PatternFilter.matches(@files, "bc")

    assert matches == [@abc, @bcd]
  end

  test "returns empty list if no matches" do
    matches = PatternFilter.matches(@files, "xyz")

    assert matches == []
  end

  test "returns files matching at least one of multiple patterns" do
    matches = PatternFilter.matches(@files, ["ab", "de"])

    assert matches == [@abc, @cde]
  end

  test "returns multiple file with line number patterns" do
    patterns = ["some_test.exs:42", "other_test.exs:58"]
    matches = PatternFilter.matches(@files, patterns)

    assert matches == patterns
  end

  test "returns a mix of matching files and files with line numbers" do
    patterns = ["some_test.exs:42", "bc", "other_test.exs:58"]
    matches = PatternFilter.matches(@files, patterns)

    assert matches == [@abc, @bcd, "some_test.exs:42", "other_test.exs:58"]
  end
end
