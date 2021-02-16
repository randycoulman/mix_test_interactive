defmodule MixTestInteractive.Config do
  @moduledoc """
  Configuration for the task and interactive watch mode.
  """

  use TypedStruct

  alias MixTestInteractive.{PatternFilter, TestFiles}

  @default_runner MixTestInteractive.PortRunner
  @default_task "test"
  @default_clear false
  @default_show_timestamp false
  @default_exclude [~r/\.#/, ~r{priv/repo/migrations}]
  @default_extra_extensions []
  @default_list_all_files &TestFiles.list/0

  typedstruct do
    field(:clear?, boolean, default: @default_clear)
    field(:exclude, [Regex.t()], default: @default_exclude)
    field(:extra_extensions, [String.t()], default: @default_extra_extensions)
    field(:failed?, boolean(), default: false)
    field(:initial_cli_args, [String.t()], default: [])
    field(:list_all_files, (() -> [String.t()]), default: @default_list_all_files)
    field(:patterns, [String.t()], default: [])
    field(:runner, module(), default: @default_runner)
    field(:show_timestamp?, boolean(), default: @default_show_timestamp)
    field(:stale?, boolean(), default: false)
    field(:task, String.t(), default: @default_task)
    field(:watching?, boolean(), default: true)
  end

  @application :mix_test_interactive

  @options [
    watch: :boolean
  ]

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

  @doc """
  Create a new config struct, taking values from the command line and application environment.

  In addition to its own options, new/1 initializes its interactive mode settings from some of
  `mix test`'s options (`--failed`, `--stale`, and any filename arguments).
  """
  @spec new([String.t()]) :: t()
  def new(cli_args \\ []) do
    {opts, patterns} = OptionParser.parse!(cli_args, switches: @options ++ @mix_test_options)
    no_patterns? = Enum.empty?(patterns)
    {failed?, opts} = Keyword.pop(opts, :failed, false)
    {stale?, opts} = Keyword.pop(opts, :stale, false)
    {watching?, opts} = Keyword.pop(opts, :watch, true)

    %__MODULE__{
      clear?: get_clear(),
      exclude: get_excluded(),
      extra_extensions: get_extra_extensions(),
      failed?: no_patterns? && failed?,
      initial_cli_args: OptionParser.to_argv(opts),
      patterns: patterns,
      runner: get_runner(),
      show_timestamp?: get_show_timestamp(),
      stale?: no_patterns? && !failed? && stale?,
      task: get_task(),
      watching?: watching?
    }
  end

  @doc """
  Assemble command-line arguments to pass to `mix test`.

  Includes arguments originally passed to `mix test.interactive` when it was started
  as well as arguments based on the current interactive mode settings.
  """
  @spec cli_args(t()) :: {:ok, [String.t()]} | {:error, :no_matching_files}
  def cli_args(%__MODULE__{initial_cli_args: initial_args} = config) do
    with {:ok, args} <- args_from_settings(config) do
      {:ok, initial_args ++ args}
    end
  end

  @doc """
  Toggle file-watching mode on or off.
  """
  @spec toggle_watch_mode(t()) :: t()
  def toggle_watch_mode(config) do
    %{config | watching?: !config.watching?}
  end

  @doc """
  Provide a list of file-name filter patterns.

  Only test filenames matching one or more patterns will be run.
  """
  @spec only_patterns(t(), [String.t()]) :: t()
  def only_patterns(config, patterns) do
    config
    |> all_tests()
    |> Map.put(:patterns, patterns)
  end

  @doc """
  Update config to only run failing tests.

  Corresponds to `mix test --failed`.
  """
  @spec only_failed(t()) :: t()
  def only_failed(config) do
    config
    |> all_tests()
    |> Map.put(:failed?, true)
  end

  @doc """
  Update config to only run "stale" tests.

  Corresponds to `mix test --stale`.
  """
  @spec only_stale(t()) :: t()
  def only_stale(config) do
    config
    |> all_tests()
    |> Map.put(:stale?, true)
  end

  @doc """
  Update config to run all tests, removing any flags or filter patterns.
  """
  @spec all_tests(t()) :: t()
  def all_tests(config) do
    %{config | failed?: false, patterns: [], stale?: false}
  end

  @doc false
  def list_files_with(config, list_fn) do
    %{config | list_all_files: list_fn}
  end

  @doc """
  Return a text summary of the current interactive mode settings.
  """
  @spec summary(t()) :: String.t()
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

  defp get_show_timestamp do
    Application.get_env(@application, :timestamp, @default_show_timestamp)
  end

  defp get_excluded do
    Application.get_env(@application, :exclude, @default_exclude)
  end

  defp get_extra_extensions do
    Application.get_env(@application, :extra_extensions, @default_extra_extensions)
  end
end
