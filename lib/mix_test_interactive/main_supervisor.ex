defmodule MixTestInteractive.MainSupervisor do
  @moduledoc false
  use Supervisor

  alias MixTestInteractive.InteractiveMode
  alias MixTestInteractive.Watcher

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(opts) do
    config = Keyword.fetch!(opts, :config)
    settings = Keyword.fetch!(opts, :settings)

    children = [
      {InteractiveMode, config: config, settings: settings},
      {Watcher, config: config}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
