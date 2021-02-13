defmodule MixTestInteractive.Command do
  alias MixTestInteractive.Config

  @type response :: {:ok, Config.t()} | {:no_run, Config.t()} | :help | :quit | :unknown

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
