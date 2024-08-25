defmodule MixTestInteractive.Config do
  @moduledoc """
  Configuration for the task.
  """
  use TypedStruct

  alias MixTestInteractive.AppConfig

  @default_clear false
  @default_command {"mix", []}
  @default_exclude [~r/\.#/, ~r{priv/repo/migrations}]
  @default_extra_extensions []
  @default_runner MixTestInteractive.PortRunner
  @default_show_timestamp false
  @default_task "test"

  typedstruct do
    field :clear?, boolean, default: @default_clear
    field :command, {String.t(), [String.t()]}, default: @default_command
    field :exclude, [Regex.t()], default: @default_exclude
    field :extra_extensions, [String.t()], default: @default_extra_extensions
    field :runner, module(), default: @default_runner
    field :show_timestamp?, boolean(), default: @default_show_timestamp
    field :task, String.t(), default: @default_task
  end

  @doc """
  Create a new config struct, taking values from the application environment.
  """
  @spec new() :: t()
  def new do
    %__MODULE__{
      clear?: get_clear(),
      command: get_command(),
      exclude: get_excluded(),
      extra_extensions: get_extra_extensions(),
      runner: get_runner(),
      show_timestamp?: get_show_timestamp(),
      task: get_task()
    }
  end

  defp get_clear do
    AppConfig.get(:clear, @default_clear)
  end

  defp get_command do
    case AppConfig.get(:command, @default_command) do
      {cmd, args} = command when is_binary(cmd) and is_list(args) -> command
      command when is_binary(command) -> {command, []}
      _invalid_command -> raise ArgumentError, "command must be a binary or a {command, [arg, ...]} tuple"
    end
  end

  defp get_excluded do
    AppConfig.get(:exclude, @default_exclude)
  end

  defp get_extra_extensions do
    AppConfig.get(:extra_extensions, @default_extra_extensions)
  end

  defp get_runner do
    AppConfig.get(:runner, @default_runner)
  end

  defp get_show_timestamp do
    AppConfig.get(:timestamp, @default_show_timestamp)
  end

  defp get_task do
    AppConfig.get(:task, @default_task)
  end
end
