defmodule MixTestInteractive.Command do
  @moduledoc """
  Behaviour for interactive mode commands.

  All commands must implement this behaviour.

  It is recommended to `use` this module in the command's module:

  ```
  defmodule MyCommand do
    use MixTestInteractive.Command,
      command: "c",
      desc: "do the thing"

    # ...
  end

  This will provide overridable implementations of most of the callbacks.

  `:command` is the key sequence the user will use to invoke the command. If a more appropriate
  command name is required in the help text, you can override the `name/0` callback.

  `:desc` is the command's description.

  `:command` and `:desc` should be written so that the following pattern reads nicely in the
  usage output: `<command> to <description>`. For example, `a to run all tests`.
  """

  alias MixTestInteractive.Settings

  @type response :: {:ok, Settings.t()} | {:no_run, Settings.t()} | :help | :quit | :unknown

  @doc """
  Is the command applicable given the current configuration?

  Returns `true` by default if not overridden.
  """
  @callback applies?(Settings.t()) :: boolean()

  @doc """
  The command's description.

  Descriptions should be written to fit the pattern `<command> to <description>`.
  For example, `a to run all tests`.

  Returns the value of the `:desc` argument passed in the `use` statement.

  Not overridable.
  """
  @callback description :: String.t()

  @doc """
  The command's key sequence.

  Key sequences should be short (single character preferred) and unique.

  Returns the value of the `:command` argument passed in the `use` statement.

  Not overridable.
  """
  @callback command :: String.t()

  @doc """
  The command's name.

  Readable name for the command.

  Defaults to the `command/0`, but can be overridden to make usage output clearer.
  """
  @callback name :: String.t()

  @doc """
  Execute the command.

  Performs the desired action in response to the command.

  Most commands return an `:ok` tuple with an updated configuration, allowing
  `MixTestInteractive.InteractiveMode` to run the tests with the new configuration.

  A command can return a `:no_run` tuple with an updated configuration if the tests
  should not be run in response to the command.

  A command can return `:help` to show detailed usage information, or `:quit` to
  exit `mix test.interactive`.

  No default provided.
  """
  @callback run([String.t()], Settings.t()) :: response()

  defmacro __using__(opts) do
    description = Keyword.fetch!(opts, :desc)
    command = Keyword.fetch!(opts, :command)

    quote do
      @behaviour MixTestInteractive.Command

      @impl true
      def applies?(_settings), do: true

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
