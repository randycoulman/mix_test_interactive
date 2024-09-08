defmodule MixTestInteractive.CommandLineParser do
  @moduledoc false

  use TypedStruct

  alias MixTestInteractive.Config
  alias MixTestInteractive.Settings

  @options [
    clear: :boolean,
    watch: :boolean
  ]

  @deprecated_combined_options [
    watch: :boolean
  ]

  @mix_test_options [
    all_warnings: :boolean,
    archives_check: :boolean,
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
    seed: :integer,
    slowest: :integer,
    stale: :boolean,
    start: :boolean,
    timeout: :integer,
    trace: :boolean,
    warnings_as_errors: :boolean
  ]

  @spec parse([String.t()]) :: {Config.t(), Settings.t()}
  def parse(cli_args \\ []) do
    {mti_args, rest_args} = Enum.split_while(cli_args, &(&1 != "--"))
    {mti_opts, _args, _invalid} = OptionParser.parse(mti_args, strict: @options)

    mix_test_args =
      if rest_args == [] and mti_opts == [] do
        # There was no separator, and none of the arguments were recognized by
        # mix_test_interactive, so assume that they are all intended for mix
        # test for convenience and backwards-compatibility.
        mti_args
      else
        remove_leading_separator(rest_args)
      end

    {mix_test_opts, patterns} =
      OptionParser.parse!(mix_test_args, switches: @deprecated_combined_options ++ @mix_test_options)

    {mti_opts, mix_test_opts} = check_for_deprecated_watch_option(mti_opts, mix_test_opts)
    config = build_config(mti_opts)
    settings = build_settings(mti_opts, mix_test_opts, patterns)

    {config, settings}
  end

  defp build_config(opts) do
    Map.put(Config.load_from_environment(), :clear?, Keyword.get(opts, :clear, false))
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

  defp check_for_deprecated_watch_option(mti_opts, mix_test_opts) do
    case Keyword.pop(mix_test_opts, :watch, :not_found) do
      {:not_found, opts} ->
        {mti_opts, opts}

      {value, opts} ->
        IO.puts(:stderr, """
        DEPRECATION WARNING: The `--watch` and `--no-watch` options must
        now be separated from other `mix test` options using the `--` separator
          e.g.: `mix test.interactive --no-watch -- --stale`
        """)

        {Keyword.put_new(mti_opts, :watch, value), opts}
    end
  end

  defp remove_leading_separator([]), do: []
  defp remove_leading_separator(["--" | args]), do: args
end
