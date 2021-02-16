defmodule MixTestInteractive.Application do
  @moduledoc false

  use Application

  alias MixTestInteractive.{Config, InteractiveMode, Watcher}

  @impl Application
  def start(_type, _args) do
    config = Config.new()
    children = [{InteractiveMode, config: config}, Watcher]

    opts = [strategy: :one_for_one, name: MixTestInteractive.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
