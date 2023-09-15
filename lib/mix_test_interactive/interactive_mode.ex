defmodule MixTestInteractive.InteractiveMode do
  @moduledoc """
  Server for interactive mode.

  Processes commands from the user and requests to run tests due to file changes.
  This ensures that commands cannot be processed while tests are already running.

  Any commands that come in while the tests are running will be processed once the
  test run has completed.
  """

  use GenServer, restart: :transient

  alias MixTestInteractive.CommandProcessor
  alias MixTestInteractive.Config
  alias MixTestInteractive.Runner
  alias MixTestInteractive.Settings

  @type option :: {:config, Config.t()} | {:name | String.t()}

  @doc """
  Start the interactive mode server.
  """
  @spec start_link([option]) :: GenServer.on_start()
  def start_link(options) do
    name = Keyword.get(options, :name, __MODULE__)
    config = Keyword.fetch!(options, :config)
    initial_state = %{config: config, settings: Settings.new()}
    GenServer.start_link(__MODULE__, initial_state, name: name)
  end

  @doc """
  Process command-line arguments.
  """
  @spec command_line_arguments([String.t()]) :: :ok
  @spec command_line_arguments(GenServer.server(), [String.t()]) :: :ok
  def command_line_arguments(server \\ __MODULE__, cli_args) do
    GenServer.call(server, {:command_line_arguments, cli_args})
  end

  @doc """
  Process a command from the user.
  """
  @spec process_command(String.t()) :: :ok
  @spec process_command(GenServer.server(), String.t()) :: :ok
  def process_command(server \\ __MODULE__, command) do
    GenServer.cast(server, {:command, command})
  end

  @doc """
  Tell InteractiveMode that one or more files have changed.
  """
  @spec note_file_changed() :: :ok
  @spec note_file_changed(GenServer.server()) :: :ok
  def note_file_changed(server \\ __MODULE__) do
    GenServer.call(server, :note_file_changed, :infinity)
  end

  @impl GenServer
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl GenServer
  def handle_call({:command_line_arguments, cli_args}, _from, state) do
    settings = Settings.new(cli_args)
    {:reply, :ok, %{state | settings: settings}, {:continue, :run_tests}}
  end

  @impl GenServer
  def handle_call(:note_file_changed, _from, state) do
    if state.settings.watching? do
      run_tests(state)
    end

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_cast({:command, command}, state) do
    case CommandProcessor.call(command, state.settings) do
      {:ok, new_settings} ->
        {:noreply, %{state | settings: new_settings}, {:continue, :run_tests}}

      {:no_run, new_settings} ->
        show_usage_prompt(new_settings)
        {:noreply, %{state | settings: new_settings}}

      :help ->
        show_help(state.settings)
        {:noreply, state}

      :unknown ->
        {:noreply, state}

      :quit ->
        IO.puts("Shutting down...")
        System.stop(0)
        {:stop, :shutdown, state}
    end
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
    with {:ok, args} <- Settings.cli_args(settings),
         :ok <- Runner.run(config, args) do
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
