defmodule MixTestInteractive.Command do
  alias MixTestInteractive.Config

  @type response :: {:ok, Config.t()} | :quit | :unknown

  @callback applies?(Config.t()) :: boolean()
  @callback description :: String.t()
  @callback command :: String.t()
  @callback name :: String.t()
  @callback run([String.t()], Config.t()) :: response()

  defmacro __using__(opts) do
    description = Keyword.fetch!(opts, :desc)
    command = Keyword.fetch!(opts, :command)

    quote do
      @behaviour MixTestInteractive.Command

      @impl true
      def applies?(_config), do: true

      @impl true
      def description, do: unquote(description)

      @impl true
      def command, do: unquote(command)

      @impl true
      def name, do: unquote(command)

      defoverridable applies?: 1, name: 0
    end
  end
end

defmodule MixTestInteractive.Command.FilterPaths do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "p", desc: "run only the specified test files"

  @impl Command
  def applies?(%Config{files: []}), do: true
  def applies?(_config), do: false

  @impl Command
  def name, do: "p <files>"

  @impl Command
  def run(files, config) do
    {:ok, Config.only_files(config, files)}
  end
end

defmodule MixTestInteractive.Command.Stale do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "s", desc: "run only stale tests"

  @impl Command
  def applies?(%Config{stale?: false}), do: true
  def applies?(_config), do: false

  @impl Command
  def run(_args, config) do
    {:ok, Config.only_stale(config)}
  end
end

defmodule MixTestInteractive.Command.Failed do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "f", desc: "run only failed tests"

  @impl Command
  def applies?(%Config{failed?: false}), do: true
  def applies?(_config), do: false

  @impl Command
  def run(_args, config) do
    {:ok, Config.only_failed(config)}
  end
end

defmodule MixTestInteractive.Command.AllTests do
  alias MixTestInteractive.{Command, Config}

  use Command, command: "a", desc: "run all tests"

  @impl Command
  def applies?(%Config{failed?: true}), do: true
  def applies?(%Config{files: [_h | _t]}), do: true
  def applies?(%Config{stale?: true}), do: true
  def applies?(_config), do: false

  @impl Command
  def run(_args, config) do
    {:ok, Config.all_tests(config)}
  end
end

defmodule MixTestInteractive.Command.Quit do
  alias MixTestInteractive.Command

  use Command, command: "q", desc: "quit"

  @impl Command
  def run(_args, _config), do: :quit
end

defmodule MixTestInteractive.Command.RunTests do
  alias MixTestInteractive.Command

  use Command, command: "", desc: "trigger a test run"

  @impl Command
  def name, do: "Enter"

  @impl Command
  def run(_args, config), do: {:ok, config}
end
