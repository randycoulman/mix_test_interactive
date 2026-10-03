defmodule MixTestInteractive.FilenamePatternFilter do
  @moduledoc false

  @doc """
  Filters filenames based on one or more filename patterns.

  Returns all filenames that contain at least one of the filename patterns
  as a substring.

  If any filename pattern includes a line number, then no filtering is done
  for it and it is returned as-is.
  """
  @spec matches([String.t()], String.t() | [String.t()]) :: [String.t()]
  def matches(files, filename_pattern) when is_binary(filename_pattern) do
    matches(files, [filename_pattern])
  end

  def matches(files, filename_patterns) do
    {with_line_number, simple} =
      filename_patterns
      |> normalize_relative_filenames()
      |> Enum.split_with(&has_line_number?/1)

    files
    |> Enum.filter(&String.contains?(&1, simple))
    |> Enum.concat(with_line_number)
  end

  defp normalize_relative_filenames(filename_patterns) do
    for filename_pattern <- filename_patterns do
      case Path.safe_relative(filename_pattern) do
        {:ok, filename} -> filename
        :error -> filename_pattern
      end
    end
  end

  defp has_line_number?(filename_pattern) do
    case ExUnit.Filters.parse_paths([filename_pattern]) do
      {_path, []} -> false
      _ -> true
    end
  end
end
