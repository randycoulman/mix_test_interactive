defmodule MixTestInteractive.ConfigStore do
  use Agent

  def start_link(_initial) do
    Agent.start_link(fn -> nil end, name: __MODULE__)
  end

  def store(config) do
    Agent.update(__MODULE__, fn _ -> config end)
  end

  def config do
    Agent.get(__MODULE__, & &1)
  end
end
