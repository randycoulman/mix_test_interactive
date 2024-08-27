defmodule MixTestInteractive.MainSupervisor do
  @moduledoc false
  use Supervisor

  alias MixTestInteractive.Config
  alias MixTestInteractive.InteractiveMode
  alias MixTestInteractive.Watcher

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(opts) do
    settings = Keyword.fetch!(opts, :settings)
    config = Config.new()

    children = [
      {InteractiveMode, config: config, settings: settings},
      {Watcher, config: config}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
