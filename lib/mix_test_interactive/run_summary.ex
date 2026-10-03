defmodule MixTestInteractive.RunSummary do
  @moduledoc false
  alias MixTestInteractive.Settings

  @doc """
  Return a text summary of the current interactive mode settings.
  """
  @spec from_settings(Settings.t()) :: String.t()
  def from_settings(%Settings{} = settings) do
    [
      &header/1,
      &failed/1,
      &stale/1,
      &patterns/1,
      &all_tag_filters/1,
      &max_failures/1,
      &repeat_count/1,
      &seed/1,
      &tracing/1
    ]
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

  defp failed(%Settings{failed?: false}), do: nil
  defp failed(%Settings{failed?: true}), do: "Failed tests"

  defp header(%Settings{} = settings) do
    if Settings.all_tests?(settings), do: "Ran all tests", else: "Ran selected tests:"
  end

  defp max_failures(%Settings{max_failures: nil}), do: nil

  defp max_failures(%Settings{} = settings) do
    "Max failures: #{settings.max_failures}"
  end

  defp patterns(%Settings{patterns: []}), do: nil

  defp patterns(%Settings{} = settings) do
    "Filename patterns: " <> inspect(settings.patterns)
  end

  defp repeat_count(%Settings{repeat_count: nil}), do: nil

  defp repeat_count(%Settings{} = settings) do
    "Repeat until failure: #{settings.repeat_count}"
  end

  defp seed(%Settings{seed: nil}), do: nil

  defp seed(%Settings{} = settings) do
    "Seed: #{settings.seed}"
  end

  defp stale(%Settings{stale?: false}), do: nil
  defp stale(%Settings{stale?: true}), do: "Stale tests"

  defp tracing(%Settings{tracing?: false}), do: nil

  defp tracing(%Settings{}) do
    "Tracing: ON"
  end

  defp tag_filters(_label, []), do: nil

  defp tag_filters(label, tags) do
    label <> ": " <> inspect(tags)
  end
end
