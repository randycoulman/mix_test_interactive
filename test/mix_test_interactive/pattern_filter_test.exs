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

  test "returns only patterns if any is a file with line number" do
    patterns = ["a", "some_test.exs:42"]
    matches = PatternFilter.matches(@files, patterns)

    assert matches == patterns
  end
end
