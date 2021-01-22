defmodule MixTestInteractive.CommandProcessor do
  @moduledoc false

  alias MixTestInteractive.Config
  alias MixTestInteractive.Command
  alias MixTestInteractive.Command.{AllTests, Failed, FilterPaths, Help, Quit, RunTests, Stale}

  @spec call(String.t() | :eof, Config.t()) :: Command.response()

  @commands [
    FilterPaths,
    Stale,
    Failed,
    AllTests,
    RunTests,
    Help,
    Quit
  ]

  def call(:eof, _config), do: :quit

  def call(command_line, config) when is_binary(command_line) do
    case String.split(command_line) do
      [] -> process_command("", [], config)
      [command | args] -> process_command(command, args, config)
    end
  end

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
