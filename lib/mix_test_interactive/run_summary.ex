defmodule MixTestInteractive.RunSummary do
  @moduledoc false
  alias MixTestInteractive.Settings

  @doc """
  Return a text summary of the current interactive mode settings.
  """
  @spec from_settings(Settings.t()) :: String.t()
  def from_settings(%Settings{} = settings) do
    [&base_summary/1, &all_tag_filters/1, &max_failures/1, &repeat_count/1, &seed/1, &tracing/1]
    |> Enum.flat_map(fn fun -> List.wrap(fun.(settings)) end)
    |> Enum.join("\n")
  end

  defp all_tag_filters(%Settings{} = settings) do
    Enum.reject(
      [
        tag_filters("Excluding tags", settings.excludes),
        tag_filters("Including tags", settings.includes),
        tag_filters("Only tags", settings.only)
      ],
      &is_nil/1
    )
  end

  defp base_summary(%Settings{} = settings) do
    cond do
      settings.failed? ->
        "Ran only failed tests"

      settings.stale? ->
        "Ran only stale tests"

      !Enum.empty?(settings.patterns) ->
        "Ran all test files matching #{Enum.join(settings.patterns, ", ")}"

      true ->
        "Ran all tests"
    end
  end

  defp max_failures(%Settings{max_failures: nil}), do: nil

  defp max_failures(%Settings{} = settings) do
    "Max failures: #{settings.max_failures}"
  end

  defp repeat_count(%Settings{repeat_count: nil}), do: nil

  defp repeat_count(%Settings{} = settings) do
    "Repeat until failure: #{settings.repeat_count}"
  end

  def seed(%Settings{seed: nil}), do: nil

  def seed(%Settings{} = settings) do
    "Seed: #{settings.seed}"
  end

  defp tracing(%Settings{tracing?: false}), do: nil

  defp tracing(%Settings{}) do
    "Tracing: ON"
  end

  defp tag_filters(_label, []), do: nil

  defp tag_filters(label, tags) do
    label <> ": " <> inspect(tags)
  end
end
