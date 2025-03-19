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
    ansi_enabled: :boolean,
    arg: :keep,
    clear: :boolean,
    command: :string,
    exclude: :keep,
    extra_extensions: :keep,
    help: :boolean,
    runner: :string,
    task: :string,
    timestamp: :boolean,
    version: :boolean,
    watch: :boolean
  ]

  @usage """
  Usage:
    mix test.interactive <mti args> [-- <mix test args>]
    mix test.interactive <mix test args>
    mix test.interactive --help
    mix test.interactive --version

  where:
    <mti_args>:
      --(no-)ansi-enabled             Enable ANSI (colored) output when running tests
                                      (default `false` on Windows; `true` on other
                                      platforms).
      --(no-)clear                    Clear the console before each run
                                      (default: `false`)
      --command <command>/--arg <arg> Custom command and arguments for running
                                      tests (default: `"mix"` with no args)
                                      NOTE: Use `--arg` multiple times to
                                      specify more than one argument
      --exclude <regex>               Exclude files/directories from triggering
                                      test runs (default:
                                      `["~r/\.#/", "~r{priv/repo/migrations}"`])
                                      NOTE: Use `--exclude` multiple times to
                                      specify more than one regex
      --extra-extensions <extension>  Watch files with additional extensions
                                      (default: [])
                                      NOTE: Use `--extra-extensions` multiple
                                      times to specify more than one extension.
      --runner <module name>          Use a custom runner module
                                      (default: `MixTestInteractive.PortRunner`)
      --task <task name>              Run a different mix task
                                      (default: `"test"`)
      --(no-)timestamp                Display the current time before running
                                      the tests (default: `false`)
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

  @type parse_result :: {:ok, %{config: Config.t(), settings: Settings.t()} | :help | :version} | {:error, UsageError.t()}

  @spec parse([String.t()]) :: parse_result()
  def parse(cli_args \\ []) do
    with {:ok, mti_opts, mix_test_args} <- parse_mti_args(cli_args),
         {:ok, mix_test_opts, patterns} <- parse_mix_test_args(mix_test_args) do
      cond do
        Keyword.get(mti_opts, :help, false) ->
          {:ok, :help}

        Keyword.get(mti_opts, :version, false) ->
          {:ok, :version}

        true ->
          with {:ok, config} <- build_config(mti_opts) do
            settings = build_settings(mti_opts, mix_test_opts, patterns)
            {:ok, %{config: config, settings: settings}}
          end
      end
    end
  end

  @spec usage_message :: String.t()
  def usage_message, do: @usage

  defp build_config(mti_opts) do
    config =
      mti_opts
      |> Enum.reduce(Config.load_from_environment(), fn
        {:ansi_enabled, enabled?}, config -> %{config | ansi_enabled?: enabled?}
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
    {excludes, mix_test_opts} = Keyword.pop_values(mix_test_opts, :exclude)
    {failed?, mix_test_opts} = Keyword.pop(mix_test_opts, :failed, false)
    {includes, mix_test_opts} = Keyword.pop_values(mix_test_opts, :include)
    {only, mix_test_opts} = Keyword.pop_values(mix_test_opts, :only)
    {max_failures, mix_test_opts} = Keyword.pop(mix_test_opts, :max_failures)
    {repeat_count, mix_test_opts} = Keyword.pop(mix_test_opts, :repeat_until_failure)
    {seed, mix_test_opts} = Keyword.pop(mix_test_opts, :seed)
    {stale?, mix_test_opts} = Keyword.pop(mix_test_opts, :stale, false)
    {trace?, mix_test_opts} = Keyword.pop(mix_test_opts, :trace, false)
    watching? = Keyword.get(mti_opts, :watch, true)

    %Settings{
      excludes: excludes,
      failed?: no_patterns? && failed?,
      includes: includes,
      initial_cli_args: OptionParser.to_argv(mix_test_opts),
      max_failures: max_failures && to_string(max_failures),
      only: only,
      patterns: patterns,
      repeat_count: repeat_count && to_string(repeat_count),
      seed: seed && to_string(seed),
      stale?: no_patterns? && !failed? && stale?,
      tracing?: trace?,
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
    {mti_opts, patterns, invalid} = OptionParser.parse(args, strict: @options)

    cond do
      invalid == [] and patterns == [] -> {:ok, mti_opts}
      mti_opts[:help] || mti_opts[:version] -> {:ok, mti_opts}
      mti_opts == [] -> {:error, :maybe_mix_test_args}
      true -> force_parse_as_mti_args(args)
    end
  end

  defp parse_mti_option_values(mti_opts) do
    mti_opts
    |> Enum.reduce_while([], fn {name, value}, acc ->
      case parse_one_option_value(name, value) do
        {:ok, parsed} -> {:cont, [{name, parsed} | acc]}
        error -> {:halt, error}
      end
    end)
    |> case do
      {:error, _error} = error -> error
      new_opts -> {:ok, Enum.reverse(new_opts)}
    end
  end

  defp parse_one_option_value(:exclude, exclude) do
    {:ok, Regex.compile!(exclude)}
  rescue
    error ->
      {:error, UsageError.exception("--exclude '#{exclude}': #{Exception.message(error)}")}
  end

  defp parse_one_option_value(:runner, runner) do
    module = runner |> String.split(".") |> Module.concat()

    if function_exported?(module, :run, 2) do
      {:ok, module}
    else
      {:error,
       UsageError.exception(
         "--runner: '#{runner}' must name a module that implements the `MixTestInteractive.TestRunner` behaviour"
       )}
    end
  end

  defp parse_one_option_value(_name, value), do: {:ok, value}

  defp combine_multiples(opts) do
    @options
    |> Enum.filter(fn {_name, type} -> type == :keep end)
    |> Enum.reduce(opts, fn {name, _type}, acc ->
      case Keyword.pop_values(acc, name) do
        {[], _new_opts} -> acc
        {values, new_opts} -> Keyword.put(new_opts, name, values)
      end
    end)
  end
end
