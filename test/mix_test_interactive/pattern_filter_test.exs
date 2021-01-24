defmodule MixTestInteractive.PatternFilterTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.PatternFilter

  @abc "test/project/abc_test.exs"
  @bcd "test/project/bcd_test.exs"
  @def "test/project/def_test.exs"

  @files [@abc, @bcd, @def]

  test "returns files matching a pattern" do
    matches = PatternFilter.matches(@files, "bc")

    assert matches == [@abc, @bcd]
  end

  test "returns empty list if no matches" do
    matches = PatternFilter.matches(@files, "xyz")

    assert matches == []
  end

  test "returns files matching at least one of multiple patterns" do
    matches = PatternFilter.matches(@files, ["a", "f"])

    assert matches == [@abc, @def]
  end
end
