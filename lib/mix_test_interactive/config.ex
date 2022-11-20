defmodule MixTestInteractive.Config do
  @moduledoc """
  Configuration for the task.
  """

  use TypedStruct

  @default_runner MixTestInteractive.PortRunner
  @default_task "test"
  @default_before_task []
  @default_after_task []
  @default_clear false
  @default_show_timestamp false
  @default_exclude [~r/\.#/, ~r{priv/repo/migrations}]
  @default_extra_extensions []

  typedstruct do
    field(:clear?, boolean, default: @default_clear)
    field(:exclude, [Regex.t()], default: @default_exclude)
    field(:extra_extensions, [String.t()], default: @default_extra_extensions)
    field(:runner, module(), default: @default_runner)
    field(:show_timestamp?, boolean(), default: @default_show_timestamp)
    field(:task, String.t(), default: @default_task)
    field(:before_task, [[String.t()]], default: @default_before_task)
    field(:after_task, [[String.t()]], default: @default_after_task)
  end

  @application :mix_test_interactive

  @doc """
  Create a new config struct, taking values from the application environment.
  """
  @spec new() :: t()
  def new() do
    %__MODULE__{
      clear?: get_clear(),
      exclude: get_excluded(),
      extra_extensions: get_extra_extensions(),
      runner: get_runner(),
      show_timestamp?: get_show_timestamp(),
      task: get_task(),
      before_task: get_before_task(),
      after_task: get_after_task()
    }
  end

  defp get_runner do
    Application.get_env(@application, :runner, @default_runner)
  end

  defp get_task do
    Application.get_env(@application, :task, @default_task)
  end

  defp get_before_task do
    Application.get_env(@application, :before_task, @default_before_task)
  end

  defp get_after_task do
    Application.get_env(@application, :after_task, @default_after_task)
  end

  defp get_clear do
    Application.get_env(@application, :clear, @default_clear)
  end

  defp get_show_timestamp do
    Application.get_env(@application, :timestamp, @default_show_timestamp)
  end

  defp get_excluded do
    Application.get_env(@application, :exclude, @default_exclude)
  end

  defp get_extra_extensions do
    Application.get_env(@application, :extra_extensions, @default_extra_extensions)
  end
end
