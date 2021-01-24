defmodule MixTestInteractive.PatternFilter do
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
