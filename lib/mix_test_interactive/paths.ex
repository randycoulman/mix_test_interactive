defmodule MixTestInteractive.Paths do
  @moduledoc false

  alias MixTestInteractive.Config

  @elixir_source_endings ~w(.erl .ex .exs .eex .leex .xrl .yrl .hrl)
  @ignored_dirs ~w(deps/ _build/)

  @doc """
  Determines if we should respond to changes in a file.
  """
  @spec watching?(String.t(), Config.t()) :: boolean
  def watching?(path, config \\ %Config{}) do
    watched_directory?(path) and elixir_extension?(path, config.extra_extensions) and
      not excluded?(config, path)
  end

  defp excluded?(config, path) do
    config.exclude
    |> Enum.map(fn pattern -> Regex.match?(pattern, path) end)
    |> Enum.any?()
  end

  defp watched_directory?(path) do
    not String.starts_with?(path, @ignored_dirs)
  end

  defp elixir_extension?(path, extra_extensions) do
    String.ends_with?(path, @elixir_source_endings ++ extra_extensions)
  end
end
