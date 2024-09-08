defmodule MixTestInteractive.CommandLineParser do
  @moduledoc false

  use TypedStruct

  alias MixTestInteractive.Config
  alias MixTestInteractive.Settings

  @options [
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
    {opts, patterns} = OptionParser.parse!(cli_args, switches: @options ++ @mix_test_options)
    no_patterns? = Enum.empty?(patterns)
    {failed?, opts} = Keyword.pop(opts, :failed, false)
    {stale?, opts} = Keyword.pop(opts, :stale, false)
    {watching?, opts} = Keyword.pop(opts, :watch, true)

    settings = %Settings{
      failed?: no_patterns? && failed?,
      initial_cli_args: OptionParser.to_argv(opts),
      patterns: patterns,
      stale?: no_patterns? && !failed? && stale?,
      watching?: watching?
    }

    {Config.new(), settings}
  end
end
