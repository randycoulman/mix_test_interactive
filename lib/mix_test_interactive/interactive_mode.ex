defmodule MixTestInteractive.InteractiveMode do
  @moduledoc """
  Server for interactive mode.

  Processes commands from the user and requests to run tests due to file changes.
  This ensures that commands cannot be processed while tests are already running.

  Any commands that come in while the tests are running will be processed once the
  test run has completed.
  """

  use GenServer

  alias MixTestInteractive.{CommandProcessor, Config, Runner, Settings}

  @type option :: {:config, Config.t()}

  @doc """
  Start the interactive mode server.
  """
  @spec start_link([option]) :: GenServer.on_start()
  def start_link(options) do
    config = Keyword.fetch!(options, :config)
    initial_state = %{config: config, settings: Settings.new()}
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  @doc """
  Initialize from command-line arguments.
  """
  @spec initialize([String.t()]) :: :ok
  def initialize(cli_args) do
    GenServer.call(__MODULE__, {:initialize, cli_args})
  end

  @doc """
  Process a command from the user.
  """
  @spec process_command(String.t()) :: :ok | :quit
  def process_command(command) do
    GenServer.call(__MODULE__, {:command, command})
  end

  @doc """
  Tell InteractiveMode that one or more files have changed.
  """
  @spec note_file_changed() :: :ok
  def note_file_changed do
    GenServer.call(__MODULE__, :note_file_changed, :infinity)
  end

  @impl GenServer
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl GenServer
  def handle_call({:initialize, cli_args}, _from, state) do
    settings = Settings.new(cli_args)
    {:reply, :ok, %{state | settings: settings}, {:continue, :run_tests}}
  end

  @impl GenServer
  def handle_call({:command, command}, _from, state) do
    case CommandProcessor.call(command, state.settings) do
      {:ok, new_settings} ->
        {:reply, :ok, %{state | settings: new_settings}, {:continue, :run_tests}}

      {:no_run, new_settings} ->
        show_usage_prompt(new_settings)
        {:reply, :ok, %{state | settings: new_settings}}

      :help ->
        show_help(state.settings)
        {:reply, :ok, state}

      :unknown ->
        {:reply, :ok, state}

      :quit ->
        {:reply, :quit, state}
    end
  end

  @impl GenServer
  def handle_call(:note_file_changed, _from, state) do
    if state.settings.watching? do
      run_tests(state)
    end

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_continue(:run_tests, state) do
    run_tests(state)
    {:noreply, state}
  end

  defp run_tests(%{config: config, settings: settings}) do
    :ok = do_run_tests(config, settings)
    show_summary(settings)
    show_usage_prompt(settings)
  end

  defp do_run_tests(config, settings) do
    with :ok <- Runner.run(config, settings) do
      :ok
    else
      {:error, :no_matching_files} ->
        [:red, "No matching tests found"]
        |> IO.ANSI.format()
        |> IO.puts()

        :ok

      error ->
        error
    end
  end

  defp show_summary(settings) do
    IO.puts("")

    settings
    |> Settings.summary()
    |> IO.puts()
  end

  defp show_usage_prompt(settings) do
    IO.puts("")

    if settings.watching? do
      IO.puts("Watching for file changes...")
    else
      IO.puts("Ignoring file changes")
    end

    IO.puts("")

    [:bright, "Usage: ?", :normal, " to show more"]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp show_help(settings) do
    IO.puts("")

    settings
    |> CommandProcessor.usage()
    |> IO.puts()
  end
end
