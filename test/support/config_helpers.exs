defmodule ConfigHelpers do
  @moduledoc false

  def compare_config?(left, right) do
    %{left | exclude: nil} == %{right | exclude: nil} and
      compare_regexes?(left.exclude, right.exclude)
  end

  def compare_regexes?(left, right) do
    left = Enum.map(left, &Regex.source/1)
    right = Enum.map(right, &Regex.source/1)
    left == right
  end

  def regex_in?(%Regex{source: source}, list) do
    Enum.any?(list, &(&1.source == source))
  end
end
