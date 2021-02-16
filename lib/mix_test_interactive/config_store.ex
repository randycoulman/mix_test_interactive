defmodule MixTestInteractive.ConfigStore do
  @moduledoc """
  Stores the current configuration, making it available to the file watcher.

  The configuration is mainly managed by `MixTestInteractive.InteractiveMode`, but
  must be shared with `MixTestInteractive.Watcher`, so is stored via this module.
  """
  use Agent

  alias MixTestInteractive.Config

  @doc """
  Start the store.
  """
  @spec start_link([]) :: Agent.on_start()
  def start_link(_initial) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  @doc """
  Store a new configuration.
  """
  @spec store(Config.t()) :: :ok
  def store(config) do
    Agent.update(__MODULE__, fn _ -> config end)
  end

  @doc """
  Return the current configuration.
  """
  @spec config() :: Config.t()
  def config do
    Agent.get(__MODULE__, & &1)
  end
end
