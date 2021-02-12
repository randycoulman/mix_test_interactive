defmodule MixTestInteractive.PortRunner do
  @moduledoc """
  Run the tasks in a new OS process via ports
  """

  @application :mix_test_interactive

  alias MixTestInteractive.Config

  @doc """
  Run tests using the runner from the config.
  """
  def run(%Config{} = config, os_type \\ :os.type(), runner \\ &System.cmd/3) do
    with {:ok, cli_args} <- Config.cli_args(config),
         command <- [config.task | cli_args] do
      case os_type do
        {:win32, _} ->
          runner.("mix", command,
            env: [{"MIX_ENV", "test"}],
            into: IO.stream(:stdio, :line)
          )

        _ ->
          command = enable_ansi(command)

          Path.join(:code.priv_dir(@application), "zombie_killer")
          |> runner.(["mix" | command],
            env: [{"MIX_ENV", "test"}],
            into: IO.stream(:stdio, :line)
          )
      end

      :ok
    end
  end

  defp enable_ansi(command) do
    enable_command = "Application.put_env(:elixir, :ansi_enabled, true);"

    run =
      if Enum.member?(command, "--no-start") do
        ["run", "--no-start", "-e"]
      else
        ["run", "-e"]
      end

    ["do"] ++ run ++ [enable_command, ","] ++ command
  end
end
