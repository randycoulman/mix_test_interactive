defmodule MixTestInteractive.CommandProcessor do
  @moduledoc """
  Processes interactive mode commands.
  """

  alias MixTestInteractive.{Command, Settings}

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
  @spec call(String.t() | :eof, Settings.t()) :: response()
  def call(:eof, _settings), do: :quit

  def call(command_line, settings) when is_binary(command_line) do
    case String.split(command_line) do
      [] -> process_command("", [], settings)
      [command | args] -> process_command(command, args, settings)
    end
  end

  @doc """
  Returns an ANSI-formatted usage summary.

  Includes only commands that are applicable to the current configuration.
  """
  @spec usage(Settings.t()) :: IO.chardata()
  def usage(settings) do
    usage =
      settings
      |> applicable_commands()
      |> Enum.flat_map(&usage_line/1)

    ([:bright, "Usage:\n", :normal] ++ usage)
    |> IO.ANSI.format()
  end

  defp usage_line(command) do
    ["› ", :bright, command.name, :normal, " to ", command.description, ".\n"]
    |> IO.ANSI.format_fragment()
  end

  defp process_command(command, args, settings) do
    case settings
         |> applicable_commands()
         |> Enum.find(nil, &(&1.command == command)) do
      nil -> :unknown
      cmd -> cmd.run(args, settings)
    end
  end

  defp applicable_commands(settings) do
    Enum.filter(@commands, & &1.applies?(settings))
  end
end
