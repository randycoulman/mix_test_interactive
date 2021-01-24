defmodule MixTestInteractive.PatternFilter do
  def matches(files, patterns) do
    Enum.filter(files, &String.contains?(&1, patterns))
  end
end
