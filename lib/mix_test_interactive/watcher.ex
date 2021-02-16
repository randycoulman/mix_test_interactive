defmodule MixTestInteractive.Watcher do
  @moduledoc """
  A server that runs tests whenever source files change.
  """

  use GenServer

  alias MixTestInteractive.{InteractiveMode, MessageInbox, Paths}

  require Logger

  @doc """
  Start the file watcher.
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
    config = InteractiveMode.config()
    path = to_string(path)

    if Paths.watching?(path, config) do
      InteractiveMode.note_file_changed()
      MessageInbox.flush()
    end

    {:noreply, state}
  end
end
