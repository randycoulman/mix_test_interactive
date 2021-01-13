defmodule MixTestInteractive.Config do
  @moduledoc """
  Responsible for gathering and packaging the configuration for the task.
  """
  @application :mix_test_interactive

  @default_runner MixTestInteractive.PortRunner
  @default_tasks ~w(test)
  @default_clear false
  @default_timestamp false
  @default_exclude [~r/\.#/, ~r{priv/repo/migrations}]
  @default_extra_extensions []
  @default_cli_executable "mix"

  defstruct clear: @default_clear,
            cli_executable: @default_cli_executable,
            exclude: @default_exclude,
            extra_extensions: @default_extra_extensions,
            failed?: false,
            files: [],
            initial_cli_args: [],
            runner: @default_runner,
            stale?: false,
            tasks: @default_tasks,
            timestamp: @default_timestamp

  @spec new([String.t()]) :: %__MODULE__{}
  @doc """
  Create a new config struct, taking values from the ENV
  """
  def new(cli_args \\ []) do
    {failed?, args} = delete_if_present(cli_args, "--failed")
    {stale?, args} = delete_if_present(args, "--stale")

    %__MODULE__{
      clear: get_clear(),
      cli_executable: get_cli_executable(),
      exclude: get_excluded(),
      extra_extensions: get_extra_extensions(),
      failed?: failed?,
      initial_cli_args: args,
      runner: get_runner(),
      stale?: stale?,
      tasks: get_tasks(),
      timestamp: get_timestamp()
    }
  end

  def cli_args(%__MODULE__{initial_cli_args: initial_args} = config) do
    initial_args ++ args_from_settings(config)
  end

  def only_files(config, files) do
    %{config | files: files}
  end

  def clear_filters(config) do
    %{config | files: []}
  end

  def only_failed(config) do
    %{config | failed?: true}
  end

  def only_stale(config) do
    %{config | stale?: true}
  end

  def clear_flags(config) do
    %{config | failed?: false, stale?: false}
  end

  defp delete_if_present(list, element) do
    {Enum.member?(list, element), List.delete(list, element)}
  end

  defp args_from_settings(%__MODULE__{failed?: true}) do
    # --failed doesn't work with --stale or with any filenames
    ["--failed"]
  end

  defp args_from_settings(%__MODULE__{files: files, stale?: stale?}) do
    if stale? do
      ["--stale" | files]
    else
      files
    end
  end

  defp get_runner do
    Application.get_env(@application, :runner, @default_runner)
  end

  defp get_tasks do
    Application.get_env(@application, :tasks, @default_tasks)
  end

  defp get_clear do
    Application.get_env(@application, :clear, @default_clear)
  end

  defp get_timestamp do
    Application.get_env(@application, :timestamp, @default_timestamp)
  end

  defp get_excluded do
    Application.get_env(@application, :exclude, @default_exclude)
  end

  defp get_cli_executable do
    Application.get_env(@application, :cli_executable, @default_cli_executable)
  end

  defp get_extra_extensions do
    Application.get_env(@application, :extra_extensions, @default_extra_extensions)
  end
end
