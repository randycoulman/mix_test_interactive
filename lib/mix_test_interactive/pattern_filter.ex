defmodule MixTestInteractive.PatternFilter do
  @moduledoc false

  @doc """
  Filters filenames based on one or more patterns.

  Returns all filenames that contain at least one of the patterns
  as a substring.

  If any pattern looks like a filename/line number pattern, then no
  filtering is done and the pattern(s) are returned as-is.  This is
  because `mix test` only allows a single filename/line number pattern
  at a time.
  """
  @spec matches([String.t()], String.t() | [String.t()]) :: [String.t()]
  def matches(files, pattern) when is_binary(pattern) do
    matches(files, [pattern])
  end

  def matches(files, patterns) do
    if any_line_number_patterns?(patterns) do
      patterns
    else
      Enum.filter(files, &String.contains?(&1, patterns))
    end
  end

  defp any_line_number_patterns?(patterns) do
    Enum.any?(patterns, &is_line_number_pattern?/1)
  end

  defp is_line_number_pattern?(pattern) do
    case ExUnit.Filters.parse_path(pattern) do
      {_path, []} -> false
      _ -> true
    end
  end
end
