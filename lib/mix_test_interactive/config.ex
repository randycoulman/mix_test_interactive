defmodule MixTestInteractive.Config do
  @moduledoc """
  Responsible for gathering and packaging the configuration for the task.
  """

  alias MixTestInteractive.{PatternFilter, TestFiles}

  @application :mix_test_interactive

  @mix_test_options [
    archives_check: :boolean,
    color: :boolean,
    compile: :boolean,
    cover: :boolean,
    deps_check: :boolean,
    elixir_version_check: :boolean,
    exclude: :keep,
    export_coverage: :string,
    failed: :boolean,
    force: :boolean,
    formatter: :keep,
    include: :keep,
    listen_on_stdin: :boolean,
    max_cases: :integer,
    max_failures: :integer,
    only: :keep,
    partitions: :integer,
    preload_modules: :boolean,
    raise: :boolean,
    seed: :integer,
    slowest: :integer,
    stale: :boolean,
    start: :boolean,
    timeout: :integer,
    trace: :boolean
  ]

  @default_runner MixTestInteractive.PortRunner
  @default_task "test"
  @default_clear false
  @default_timestamp false
  @default_exclude [~r/\.#/, ~r{priv/repo/migrations}]
  @default_extra_extensions []
  @default_list_all_files &TestFiles.list/0

  defstruct clear: @default_clear,
            exclude: @default_exclude,
            extra_extensions: @default_extra_extensions,
            failed?: false,
            initial_cli_args: [],
            list_all_files: @default_list_all_files,
            patterns: [],
            runner: @default_runner,
            stale?: false,
            task: @default_task,
            timestamp: @default_timestamp

  @spec new([String.t()]) :: %__MODULE__{}
  @doc """
  Create a new config struct, taking values from the ENV
  """
  def new(cli_args \\ []) do
    {opts, patterns} = OptionParser.parse!(cli_args, switches: @mix_test_options)
    no_patterns? = Enum.empty?(patterns)
    {failed?, opts} = Keyword.pop(opts, :failed, false)
    {stale?, opts} = Keyword.pop(opts, :stale, false)

    %__MODULE__{
      clear: get_clear(),
      exclude: get_excluded(),
      extra_extensions: get_extra_extensions(),
      failed?: no_patterns? && failed?,
      initial_cli_args: OptionParser.to_argv(opts),
      patterns: patterns,
      runner: get_runner(),
      stale?: no_patterns? && !failed? && stale?,
      task: get_task(),
      timestamp: get_timestamp()
    }
  end

  def cli_args(%__MODULE__{initial_cli_args: initial_args} = config) do
    with {:ok, args} <- args_from_settings(config) do
      {:ok, initial_args ++ args}
    end
  end

  def only_patterns(config, patterns) do
    config
    |> all_tests()
    |> Map.put(:patterns, patterns)
  end

  def only_failed(config) do
    config
    |> all_tests()
    |> Map.put(:failed?, true)
  end

  def only_stale(config) do
    config
    |> all_tests()
    |> Map.put(:stale?, true)
  end

  def all_tests(config) do
    %{config | failed?: false, patterns: [], stale?: false}
  end

  def list_files_with(config, list_fn) do
    %{config | list_all_files: list_fn}
  end

  def summary(config) do
    cond do
      config.failed? ->
        "Ran only failed tests"

      config.stale? ->
        "Ran only stale tests"

      !Enum.empty?(config.patterns) ->
        "Ran all test files matching #{Enum.join(config.patterns, ", ")}"

      true ->
        "Ran all tests"
    end
  end

  defp args_from_settings(%__MODULE__{failed?: true}) do
    {:ok, ["--failed"]}
  end

  defp args_from_settings(%__MODULE__{stale?: true}) do
    {:ok, ["--stale"]}
  end

  defp args_from_settings(%__MODULE__{patterns: patterns} = config) when length(patterns) > 0 do
    case config.list_all_files.() |> PatternFilter.matches(patterns) do
      [] -> {:error, :no_matching_files}
      files -> {:ok, files}
    end
  end

  defp args_from_settings(_config), do: {:ok, []}

  defp get_runner do
    Application.get_env(@application, :runner, @default_runner)
  end

  defp get_task do
    Application.get_env(@application, :task, @default_task)
  end

  defp get_clear do
    Application.get_env(@application, :clear, @default_clear)
  end

  defp get_timestamp do
    Application.get_env(@application, :timestamp, @default_timestamp)
  end

  defp get_excluded do
    Application.get_env(@application, :exclude, @default_exclude)
  end

  defp get_extra_extensions do
    Application.get_env(@application, :extra_extensions, @default_extra_extensions)
  end
end
