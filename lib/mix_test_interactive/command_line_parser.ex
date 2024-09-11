defmodule MixTestInteractive.CommandLineParser do
  @moduledoc false

  use TypedStruct

  alias MixTestInteractive.Config
  alias MixTestInteractive.Settings
  alias OptionParser.ParseError

  defmodule UsageError do
    @moduledoc false
    defexception [:message]

    @type t :: %__MODULE__{
            message: String.t()
          }

    def exception(other) when is_exception(other) do
      exception(Exception.message(other))
    end

    def exception(opts), do: super(opts)
  end

  @options [
    arg: :keep,
    clear: :boolean,
    command: :string,
    exclude: :keep,
    extra_extensions: :keep,
    runner: :string,
    task: :string,
    timestamp: :boolean,
    watch: :boolean
  ]

  @usage """
  Usage:
    mix_test_interactive <mti args> [-- <mix test args>]
    mix_test_interactive <mix test args>

  where:
    <mti_args>:
      --(no-)clear                    Clear the console before each run
                                      (default `false`)
      --command <command>/
      --arg <arg>                     Custom command and arguments for running
                                      tests (default: `"mix"` with no args)
                                      NOTE: Use `--arg` multiple times to specify
                                      more than one argument
      --exclude <regex>               Exclude files/directories from triggering
                                      test runs
                                      (default: `["~r/\.#/", "~r{priv/repo/migrations}"`])
                                      NOTE: Use `--exclude` multiple times to
                                      specify more than one regex
      --extra-extensions <extension>  Watch files with additional extensions
                                      (default: [])
                                      NOTE: Use `--extra-extensions` multiple times
                                      to specify more than one extension.
      --runner <module name>          Use a custom runner module
                                      (default: `MixTestInteractive.PortRunner`)
      --task <task name>              Run a different mix task (default: `"test"`)
      --(no-)timestamp                Display the current time before running the
                                      tests (default: `false`)
      --(no-)watch                    Run tests when a watched file changes
                                      (default: `true`)

    <mix_test_args>:
      any arguments accepted by `mix test`
  """

  @mix_test_options [
    all_warnings: :boolean,
    archives_check: :boolean,
    breakpoints: :boolean,
    color: :boolean,
    compile: :boolean,
    cover: :boolean,
    deps_check: :boolean,
    elixir_version_check: :boolean,
    exclude: :keep,
    exit_status: :integer,
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
    profile_require: :string,
    raise: :boolean,
    repeat_until_failure: :integer,
    seed: :integer,
    slowest: :integer,
    slowest_modules: :integer,
    stale: :boolean,
    start: :boolean,
    timeout: :integer,
    trace: :boolean,
    warnings_as_errors: :boolean
  ]

  @mix_test_aliases [
    b: :breakpoints
  ]

  @spec parse([String.t()]) :: {:ok, %{config: Config.t(), settings: Settings.t()}} | {:error, UsageError.t()}
  def parse(cli_args \\ []) do
    with {:ok, mti_opts, mix_test_args} <- parse_mti_args(cli_args),
         {:ok, mix_test_opts, patterns} <- parse_mix_test_args(mix_test_args),
         {:ok, config} <- build_config(mti_opts) do
      settings = build_settings(mti_opts, mix_test_opts, patterns)

      {:ok, %{config: config, settings: settings}}
    end
  end

  @spec usage_message :: String.t()
  def usage_message, do: @usage

  defp build_config(mti_opts) do
    config =
      mti_opts
      |> Enum.reduce(Config.load_from_environment(), fn
        {:clear, clear?}, config -> %{config | clear?: clear?}
        {:exclude, excludes}, config -> %{config | exclude: excludes}
        {:extra_extensions, extra_extensions}, config -> %{config | extra_extensions: extra_extensions}
        {:runner, runner}, config -> %{config | runner: runner}
        {:timestamp, show_timestamp?}, config -> %{config | show_timestamp?: show_timestamp?}
        {:task, task}, config -> %{config | task: task}
        _pair, config -> config
      end)
      |> handle_custom_command(mti_opts)

    {:ok, config}
  end

  defp handle_custom_command(%Config{} = config, mti_opts) do
    case Keyword.fetch(mti_opts, :command) do
      {:ok, command} -> %{config | command: {command, Keyword.get(mti_opts, :arg, [])}}
      :error -> config
    end
  end

  defp build_settings(mti_opts, mix_test_opts, patterns) do
    no_patterns? = Enum.empty?(patterns)
    {failed?, mix_test_opts} = Keyword.pop(mix_test_opts, :failed, false)
    {stale?, mix_test_opts} = Keyword.pop(mix_test_opts, :stale, false)
    watching? = Keyword.get(mti_opts, :watch, true)

    %Settings{
      failed?: no_patterns? && failed?,
      initial_cli_args: OptionParser.to_argv(mix_test_opts),
      patterns: patterns,
      stale?: no_patterns? && !failed? && stale?,
      watching?: watching?
    }
  end

  defp parse_mix_test_args(mix_test_args) do
    {mix_test_opts, patterns} =
      OptionParser.parse!(mix_test_args, aliases: @mix_test_aliases, switches: @mix_test_options)

    {:ok, mix_test_opts, patterns}
  end

  defp parse_mti_args(cli_args) do
    with {:ok, mti_opts, mix_test_args} <- parse_mti_args_raw(cli_args),
         {:ok, parsed} <- parse_mti_option_values(mti_opts) do
      {:ok, combine_multiples(parsed), mix_test_args}
    end
  end

  defp parse_mti_args_raw(cli_args) do
    case Enum.find_index(cli_args, &(&1 == "--")) do
      nil ->
        case try_parse_as_mti_args(cli_args) do
          {:ok, mti_opts} -> {:ok, mti_opts, []}
          {:error, :maybe_mix_test_args} -> {:ok, [], cli_args}
          {:error, error} -> {:error, error}
        end

      index ->
        mti_args = Enum.take(cli_args, index)

        with {:ok, mti_opts} <- force_parse_as_mti_args(mti_args) do
          mix_test_args = Enum.drop(cli_args, index + 1)
          {:ok, mti_opts, mix_test_args}
        end
    end
  end

  defp force_parse_as_mti_args(args) do
    {mti_opts, _args} = OptionParser.parse!(args, strict: @options)
    {:ok, mti_opts}
  rescue
    error in ParseError -> {:error, UsageError.exception(error)}
  end

  defp try_parse_as_mti_args(args) do
    {mti_opts, _args, invalid} = OptionParser.parse(args, strict: @options)

    cond do
      invalid == [] -> {:ok, mti_opts}
      mti_opts == [] -> {:error, :maybe_mix_test_args}
      true -> force_parse_as_mti_args(args)
    end
  end

  defp parse_mti_option_values(mti_opts) do
    {:ok, Enum.map(mti_opts, &parse_one_option_value!/1)}
  rescue
    error in UsageError -> {:error, error}
  end

  defp parse_one_option_value!({:exclude, exclude}) do
    {:exclude, Regex.compile!(exclude)}
  rescue
    error ->
      raise UsageError, "--exclude '#{exclude}': #{Exception.message(error)}"
  end

  defp parse_one_option_value!({:runner, runner}) do
    module = runner |> String.split(".") |> Module.concat()

    if function_exported?(module, :run, 2) do
      {:runner, module}
    else
      raise UsageError, message: "--runner: '#{runner}' must name a module that implements a `run/2` function"
    end
  end

  defp parse_one_option_value!(option), do: option

  defp combine_multiples(mti_opts) do
    @options
    |> Enum.filter(fn {_name, type} -> type == :keep end)
    |> Enum.reduce(mti_opts, fn {name, _type}, acc ->
      case Keyword.pop_values(acc, name) do
        {[], _new_opts} -> acc
        {values, new_opts} -> Keyword.put(new_opts, name, values)
      end
    end)
  end
end
