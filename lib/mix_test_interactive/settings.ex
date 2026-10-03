defmodule MixTestInteractive.Settings do
  @moduledoc """
  Interactive mode settings.

  Keeps track of the current settings of `MixTestInteractive.InteractiveMode`, making changes
  in response to user commands.
  """

  use TypedStruct

  alias MixTestInteractive.FilenamePatternFilter
  alias MixTestInteractive.TestFiles

  @default_list_all_files &TestFiles.list/0

  typedstruct do
    field :excludes, [String.t()], default: []
    field :failed?, boolean(), default: false
    field :filename_patterns, [String.t()], default: []
    field :includes, [String.t()], default: []
    field :initial_cli_args, [String.t()], default: []
    field :list_all_files, (-> [String.t()]), default: @default_list_all_files
    field :max_failures, String.t()
    field :only, [String.t()], default: []
    field :repeat_count, String.t()
    field :seed, String.t()
    field :stale?, boolean(), default: false
    field :tracing?, boolean(), default: false
    field :watching?, boolean(), default: true
  end

  @doc """
  Update settings to run all tests, removing any flags, filename patterns, or tag filters.
  """
  @spec all_tests(t()) :: t()
  def all_tests(%__MODULE__{} = settings) do
    %{settings | excludes: [], failed?: false, filename_patterns: [], includes: [], only: [], stale?: false}
  end

  @doc """
  Return whether the settings run all tests; that is, whether `all_tests/1`
  would leave them unchanged.
  """
  @spec all_tests?(t()) :: boolean()
  def all_tests?(%__MODULE__{} = settings) do
    all_tests(settings) == settings
  end

  @doc """
  Update settings to clear any excluded tags.
  """
  @spec clear_excludes(t()) :: t()
  def clear_excludes(%__MODULE__{} = settings) do
    %{settings | excludes: []}
  end

  @doc """
  Update settings to clear any included tags.
  """
  @spec clear_includes(t()) :: t()
  def clear_includes(%__MODULE__{} = settings) do
    %{settings | includes: []}
  end

  @doc """
  Update settings to run with unlimited failures, clearing any specified maximum
  number of failures.
  """
  @spec clear_max_failures(t()) :: t()
  def clear_max_failures(%__MODULE__{} = settings) do
    %{settings | max_failures: nil}
  end

  @doc """
  Update settings to clear any "only" tags.
  """
  @spec clear_only(t()) :: t()
  def clear_only(%__MODULE__{} = settings) do
    %{settings | only: []}
  end

  @doc """
  Update settings to run tests only once, clearing any repeat-until-failure
  count.
  """
  @spec clear_repeat_count(t()) :: t()
  def clear_repeat_count(%__MODULE__{} = settings) do
    %{settings | repeat_count: nil}
  end

  @doc """
  Update settings to run tests with a random seed, clearing any specified seed.
  """
  @spec clear_seed(t()) :: t()
  def clear_seed(%__MODULE__{} = settings) do
    %{settings | seed: nil}
  end

  @doc """
  Assemble command-line arguments to pass to `mix test`.

  Includes arguments originally passed to `mix test.interactive` when it was started
  as well as arguments based on the current interactive mode settings.
  """
  @spec cli_args(t()) :: {:ok, [String.t()]} | {:error, :no_matching_files}
  def cli_args(%__MODULE__{} = settings) do
    with {:ok, args} <- args_from_settings(settings) do
      {:ok, settings.initial_cli_args ++ args}
    end
  end

  @doc false
  def list_files_with(%__MODULE__{} = settings, list_fn) do
    %{settings | list_all_files: list_fn}
  end

  @doc """
  Toggle running of only failing tests on or off.

  Corresponds to `mix test --failed`.
  """
  @spec toggle_failed(t()) :: t()
  def toggle_failed(%__MODULE__{} = settings) do
    %{settings | failed?: !settings.failed?}
  end

  @doc """
  Toggle running of only stale tests on or off.

  Corresponds to `mix test --stale`.
  """
  @spec toggle_stale(t()) :: t()
  def toggle_stale(%__MODULE__{} = settings) do
    %{settings | stale?: !settings.stale?}
  end

  @doc """
  Toggle test tracing on or off.
  """
  @spec toggle_tracing(t()) :: t()
  def toggle_tracing(%__MODULE__{} = settings) do
    %{settings | tracing?: !settings.tracing?}
  end

  @doc """
  Toggle file-watching mode on or off.
  """
  @spec toggle_watch_mode(t()) :: t()
  def toggle_watch_mode(%__MODULE__{} = settings) do
    %{settings | watching?: !settings.watching?}
  end

  @doc """
  Exclude tests with the specified tags.

  Corresponds to `mix test --exclude <tag1> --exclude <tag2> ...`.
  """
  @spec with_excludes(t(), [String.t()]) :: t()
  def with_excludes(%__MODULE__{} = settings, excludes) do
    %{settings | excludes: excludes}
  end

  @doc """
  Run only test files matching one or more filename patterns.
  """
  @spec with_filename_patterns(t(), [String.t()]) :: t()
  def with_filename_patterns(%__MODULE__{} = settings, filename_patterns) do
    %{settings | filename_patterns: filename_patterns}
  end

  @doc """
  Include tests with the specified tags.

  Corresponds to `mix test --include <tag1> --include <tag2> ...`.
  """
  @spec with_includes(t(), [String.t()]) :: t()
  def with_includes(%__MODULE__{} = settings, includes) do
    %{settings | includes: includes}
  end

  @doc """
  Stop running tests after a maximum number of failures.

  Corresponds to `mix test --max-failures <max>`.
  """
  @spec with_max_failures(t(), String.t()) :: t()
  def with_max_failures(%__MODULE__{} = settings, max) do
    %{settings | max_failures: max}
  end

  @doc """
  Run only the tests with the specified tags.

  Corresponds to `mix test --only <tag1> --only <tag2> ...`.
  """
  @spec with_only(t(), [String.t()]) :: t()
  def with_only(%__MODULE__{} = settings, only) do
    %{settings | only: only}
  end

  @doc """
  Update settings to run tests <count> times until failure.

  Corresponds to `mix test --repeat-until-failure <count>`.
  """
  @spec with_repeat_count(t(), String.t()) :: t()
  def with_repeat_count(%__MODULE__{} = settings, count) do
    %{settings | repeat_count: count}
  end

  @doc """
  Update settings to run tests with a specific seed.

  Corresponds to `mix test --seed <seed>`.
  """
  @spec with_seed(t(), String.t()) :: t()
  def with_seed(%__MODULE__{} = settings, seed) do
    %{settings | seed: seed}
  end

  defp args_from_settings(%__MODULE{} = settings) do
    with {:ok, files} <- files_from_filename_patterns(settings) do
      {:ok, opts_from_settings(settings) ++ files}
    end
  end

  defp files_from_filename_patterns(%__MODULE__{filename_patterns: []} = _settings) do
    {:ok, []}
  end

  defp files_from_filename_patterns(%__MODULE__{filename_patterns: filename_patterns} = settings) do
    case FilenamePatternFilter.matches(settings.list_all_files.(), filename_patterns) do
      [] -> {:error, :no_matching_files}
      files -> {:ok, files}
    end
  end

  defp opts_from_settings(%__MODULE__{} = settings) do
    settings
    |> Map.from_struct()
    |> Enum.sort()
    |> Enum.flat_map(&opts_from_single_setting/1)
  end

  defp opts_from_single_setting({:excludes, excludes}) do
    Enum.flat_map(excludes, &["--exclude", &1])
  end

  defp opts_from_single_setting({:failed?, false}), do: []
  defp opts_from_single_setting({:failed?, true}), do: ["--failed"]

  defp opts_from_single_setting({:includes, includes}) do
    Enum.flat_map(includes, &["--include", &1])
  end

  defp opts_from_single_setting({:max_failures, nil}), do: []
  defp opts_from_single_setting({:max_failures, max}), do: ["--max-failures", max]

  defp opts_from_single_setting({:only, only}) do
    Enum.flat_map(only, &["--only", &1])
  end

  defp opts_from_single_setting({:repeat_count, nil}), do: []
  defp opts_from_single_setting({:repeat_count, count}), do: ["--repeat-until-failure", count]

  defp opts_from_single_setting({:seed, nil}), do: []
  defp opts_from_single_setting({:seed, seed}), do: ["--seed", seed]

  defp opts_from_single_setting({:stale?, false}), do: []
  defp opts_from_single_setting({:stale?, true}), do: ["--stale"]

  defp opts_from_single_setting({:tracing?, false}), do: []
  defp opts_from_single_setting({:tracing?, true}), do: ["--trace"]

  defp opts_from_single_setting({_key, _value}), do: []
end
