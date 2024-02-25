defmodule MixTestInteractive.Watcher do
  @moduledoc """
  A server that runs tests whenever source files change.
  """

  use GenServer

  alias MixTestInteractive.InteractiveMode
  alias MixTestInteractive.MessageInbox
  alias MixTestInteractive.Paths

  require Logger

  # The following events (among many others, depending on platform) are emitted
  # by the `FileSystem` library and are the ones that we look for in order to
  # kick off a test run.
  @trigger_events [
    :created,
    :deleted,
    :modified,
    :moved_from,
    :moved_to,
    :removed,
    :renamed
  ]

  @doc """
  Start the file watcher.
  """
  def start_link(options) do
    config = Keyword.fetch!(options, :config)
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @impl GenServer
  def init(config) do
    opts = [dirs: [Path.absname("")], name: :mix_test_watcher]

    case FileSystem.start_link(opts) do
      {:ok, _} ->
        FileSystem.subscribe(:mix_test_watcher)
        {:ok, config}

      other ->
        Logger.warning("""
        Could not start the file system monitor.
        """)

        other
    end
  end

  @impl GenServer
  def handle_info({:file_event, _, {path, events}}, config) do
    if Enum.any?(events, &(&1 in @trigger_events)) do
      path = to_string(path)

      if Paths.watching?(path, config) do
        InteractiveMode.note_file_changed()
        MessageInbox.flush()
      end
    end

    {:noreply, config}
  end
end
