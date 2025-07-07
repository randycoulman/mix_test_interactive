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
    {with_line_number, simple} =
      patterns
      |> convert_relative_filenames_to_patterns()
      |> Enum.split_with(&is_line_number_pattern?/1)

    files
    |> Enum.filter(&String.contains?(&1, simple))
    |> Enum.concat(with_line_number)
  end

  defp convert_relative_filenames_to_patterns(patterns) do
    for pattern <- patterns do
      case Path.safe_relative(pattern) do
        {:ok, filename} -> filename
        :error -> pattern
      end
    end
  end

  if Version.compare(System.version(), "1.20.0-dev") == :lt do
    defp is_line_number_pattern?(pattern) do
      case ExUnit.Filters.parse_path(pattern) do
        {_path, []} -> false
        _ -> true
      end
    end
  else
    defp is_line_number_pattern?(pattern) do
      case ExUnit.Filters.parse_paths([pattern]) do
        {_path, []} -> false
        _ -> true
      end
    end
  end
end
