defmodule MixTestInteractive.Application do
  @moduledoc false

  use Application

  alias MixTestInteractive.{Config, ConfigStore}

  @impl Application
  def start(_type, _args) do
    children = [{ConfigStore, config: %Config{}}]

    opts = [strategy: :one_for_one, name: MixTestInteractive.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
