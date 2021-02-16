defmodule MixTestInteractive.CommandProcessor do
  @moduledoc """
  Processes interactive mode commands.
  """

  alias MixTestInteractive.Config
  alias MixTestInteractive.Command

  alias MixTestInteractive.Command.{
    AllTests,
    Failed,
    Help,
    Pattern,
    Quit,
    RunTests,
    Stale,
    ToggleWatchMode
  }

  @type response :: Command.response()

  @commands [
    Pattern,
    Stale,
    Failed,
    AllTests,
    ToggleWatchMode,
    RunTests,
    Help,
    Quit
  ]

  @doc """
  Processes a single interactive mode command.
  """
  @spec call(String.t() | :eof, Config.t()) :: response()
  def call(:eof, _config), do: :quit

  def call(command_line, config) when is_binary(command_line) do
    case String.split(command_line) do
      [] -> process_command("", [], config)
      [command | args] -> process_command(command, args, config)
    end
  end

  @doc """
  Returns an ANSI-formatted usage summary.

  Includes only commands that are applicable to the current configuration.
  """
  @spec usage(Config.t()) :: IO.chardata()
  def usage(config) do
    usage =
      config
      |> applicable_commands()
      |> Enum.flat_map(&usage_line/1)

    ([:bright, "Usage:\n", :normal] ++ usage)
    |> IO.ANSI.format()
  end

  defp usage_line(command) do
    ["› ", :bright, command.name, :normal, " to ", command.description, ".\n"]
    |> IO.ANSI.format_fragment()
  end

  defp process_command(command, args, config) do
    case config
         |> applicable_commands()
         |> Enum.find(nil, &(&1.command == command)) do
      nil -> :unknown
      cmd -> cmd.run(args, config)
    end
  end

  defp applicable_commands(config) do
    Enum.filter(@commands, & &1.applies?(config))
  end
end
