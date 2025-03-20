defmodule MixTestInteractive.Config do
  @moduledoc """
  Configuration for the task.
  """
  use TypedStruct

  @application :mix_test_interactive

  typedstruct do
    field :ansi_enabled?, boolean
    field :clear?, boolean, default: false
    field :command, {String.t(), [String.t()]}, default: {"mix", []}
    field :exclude, [Regex.t()], default: [~r/\.#/, ~r{priv/repo/migrations}]
    field :extra_extensions, [String.t()], default: []
    field :runner, module(), default: MixTestInteractive.PortRunner
    field :show_timestamp?, boolean(), default: false
    field :task, String.t(), default: "test"
  end

  @doc """
  Create a new config struct, taking values from the application environment.
  """
  @spec load_from_environment :: t()
  def load_from_environment do
    new()
    |> load(:ansi_enabled, rename: :ansi_enabled?)
    |> load(:clear, rename: :clear?)
    |> load(:command, transform: &parse_command/1)
    |> load(:exclude)
    |> load(:extra_extensions)
    |> load(:runner)
    |> load(:timestamp, rename: :show_timestamp?)
    |> load(:task)
  end

  @doc false
  def new do
    os_type = ProcessTree.get(:os_type, default: :os.type())

    default_ansi_enabled(%__MODULE__{}, os_type)
  end

  defp load(%__MODULE__{} = config, app_key, opts \\ []) do
    config_key = Keyword.get(opts, :rename, app_key)
    transform = Keyword.get(opts, :transform, & &1)

    case config(app_key) do
      {:ok, value} -> Map.put(config, config_key, transform.(value))
      :error -> config
    end
  end

  defp config(key) do
    case ProcessTree.get(key) do
      nil -> Application.fetch_env(@application, key)
      value -> {:ok, value}
    end
  end

  defp default_ansi_enabled(%__MODULE__{} = config, {:win32, _os_name} = _os_type) do
    %{config | ansi_enabled?: false}
  end

  defp default_ansi_enabled(%__MODULE__{} = config, _os_type) do
    %{config | ansi_enabled?: true}
  end

  defp parse_command({cmd, args} = command) when is_binary(cmd) and is_list(args), do: command
  defp parse_command(command) when is_binary(command), do: {command, []}

  defp parse_command(_invalid_command),
    do: raise(ArgumentError, "command must be a binary or a {command, [arg, ...]} tuple")
end
