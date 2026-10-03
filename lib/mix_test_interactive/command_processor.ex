defmodule MixTestInteractive.CommandProcessor do
  @moduledoc """
  Processes interactive mode commands.
  """

  alias MixTestInteractive.Command
  alias MixTestInteractive.Command.AllTests
  alias MixTestInteractive.Command.Exclude
  alias MixTestInteractive.Command.FilenamePattern
  alias MixTestInteractive.Command.Help
  alias MixTestInteractive.Command.Include
  alias MixTestInteractive.Command.MaxFailures
  alias MixTestInteractive.Command.NamePattern
  alias MixTestInteractive.Command.Only
  alias MixTestInteractive.Command.Quit
  alias MixTestInteractive.Command.RepeatUntilFailure
  alias MixTestInteractive.Command.RunTests
  alias MixTestInteractive.Command.Seed
  alias MixTestInteractive.Command.ToggleFailed
  alias MixTestInteractive.Command.ToggleStale
  alias MixTestInteractive.Command.ToggleTracing
  alias MixTestInteractive.Command.ToggleWatchMode
  alias MixTestInteractive.Settings

  @type response :: Command.response()

  @commands [
    AllTests,
    Exclude,
    FilenamePattern,
    Help,
    Include,
    MaxFailures,
    NamePattern,
    Only,
    Quit,
    RepeatUntilFailure,
    RunTests,
    Seed,
    ToggleFailed,
    ToggleStale,
    ToggleTracing,
    ToggleWatchMode
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
  """
  @spec usage :: IO.chardata()
  def usage do
    usage =
      @commands
      |> Enum.sort_by(& &1.command())
      |> Enum.flat_map(&usage_line/1)

    IO.ANSI.format([:bright, "Usage:\n", :normal] ++ usage)
  end

  defp usage_line(command) do
    IO.ANSI.format_fragment(["› ", :bright, command.name(), :normal, " to ", command.description(), ".\n"])
  end

  defp process_command(command, args, settings) do
    case Enum.find(@commands, nil, &(&1.command() == command)) do
      nil -> :unknown
      cmd -> cmd.run(args, settings)
    end
  end
end
