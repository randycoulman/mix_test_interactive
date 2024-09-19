defmodule MixTestInteractive.Settings do
  @moduledoc """
  Interactive mode settings.

  Keeps track of the current settings of `MixTestInteractive.InteractiveMode`, making changes
  in response to user commands.
  """

  use TypedStruct

  alias MixTestInteractive.PatternFilter
  alias MixTestInteractive.TestFiles

  @default_list_all_files &TestFiles.list/0

  typedstruct do
    field :failed?, boolean(), default: false
    field :initial_cli_args, [String.t()], default: []
    field :list_all_files, (-> [String.t()]), default: @default_list_all_files
    field :patterns, [String.t()], default: []
    field :seed, String.t()
    field :stale?, boolean(), default: false
    field :watching?, boolean(), default: true
  end

  @doc """
  Update settings to run all tests, removing any flags or filter patterns.
  """
  @spec all_tests(t()) :: t()
  def all_tests(%__MODULE__{} = settings) do
    %{settings | failed?: false, patterns: [], stale?: false}
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
  Update settings to only run failing tests.

  Corresponds to `mix test --failed`.
  """
  @spec only_failed(t()) :: t()
  def only_failed(%__MODULE__{} = settings) do
    settings
    |> all_tests()
    |> Map.put(:failed?, true)
  end

  @doc """
  Provide a list of file-name filter patterns.

  Only test filenames matching one or more patterns will be run.
  """
  @spec only_patterns(t(), [String.t()]) :: t()
  def only_patterns(%__MODULE__{} = settings, patterns) do
    settings
    |> all_tests()
    |> Map.put(:patterns, patterns)
  end

  @doc """
  Update settings to only run "stale" tests.

  Corresponds to `mix test --stale`.
  """
  @spec only_stale(t()) :: t()
  def only_stale(%__MODULE__{} = settings) do
    settings
    |> all_tests()
    |> Map.put(:stale?, true)
  end

  @doc """
  Return a text summary of the current interactive mode settings.
  """
  @spec summary(t()) :: String.t()
  def summary(%__MODULE__{} = settings) do
    run_summary =
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

    case settings.seed do
      nil -> run_summary
      seed -> run_summary <> " with seed: #{seed}"
    end
  end

  @doc """
  Update settings to run tests with a specific seed.

  Corresponds to `mix test --seed <seed>`.
  """
  @spec with_seed(t(), String.t()) :: t()
  def with_seed(%__MODULE__{} = settings, seed) do
    %{settings | seed: seed}
  end

  @doc """
  Toggle file-watching mode on or off.
  """
  @spec toggle_watch_mode(t()) :: t()
  def toggle_watch_mode(%__MODULE__{} = settings) do
    %{settings | watching?: !settings.watching?}
  end

  defp args_from_settings(%__MODULE{} = settings) do
    with {:ok, files} <- files_from_patterns(settings) do
      {:ok, opts_from_settings(settings) ++ files}
    end
  end

  defp files_from_patterns(%__MODULE__{patterns: []} = _settings) do
    {:ok, []}
  end

  defp files_from_patterns(%__MODULE__{patterns: patterns} = settings) do
    case PatternFilter.matches(settings.list_all_files.(), patterns) do
      [] -> {:error, :no_matching_files}
      files -> {:ok, files}
    end
  end

  defp opts_from_settings(%__MODULE__{} = settings) do
    [settings.failed? && "--failed", settings.seed && ["--seed", to_string(settings.seed)], settings.stale? && "--stale"]
    |> Enum.filter(& &1)
    |> List.flatten()
  end
end
