defmodule MixTestInteractive.Watcher do
  use GenServer

  alias MixTestInteractive.{ConfigStore, InteractiveMode, MessageInbox, Paths}

  require Logger

  @moduledoc """
  A server that runs tests whenever source files change.
  """

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    opts = [dirs: [Path.absname("")], name: :mix_test_watcher]

    case FileSystem.start_link(opts) do
      {:ok, _} ->
        FileSystem.subscribe(:mix_test_watcher)
        {:ok, []}

      other ->
        Logger.warn("""
        Could not start the file system monitor.
        """)

        other
    end
  end

  @impl GenServer
  def handle_info({:file_event, _, {path, _events}}, state) do
    config = ConfigStore.config()
    path = to_string(path)

    if config.watching? && Paths.watching?(path, config) do
      InteractiveMode.run(config)
      MessageInbox.flush()
    end

    {:noreply, state}
  end
end
