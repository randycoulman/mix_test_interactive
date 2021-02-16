defmodule MixTestInteractive.PortRunner do
  @moduledoc """
  Run the tasks in a new OS process via `Port`s.

  On Unix-like operating systems, it runs the tests using a `zombie_killer` script
  as describe in https://hexdocs.pm/elixir/Port.html#module-zombie-operating-system-processes.
  It also enable ANSI output mode.

  On Windows, `mix` is run directly and ANSI mode is not enabled, as it is not always
  supported by Windows command processors.
  """

  @application :mix_test_interactive
  @type runner ::
          (String.t(), [String.t()], keyword() ->
             {Collectable.t(), exit_status :: non_neg_integer()})
  @type os_type :: {atom(), atom()}

  alias MixTestInteractive.{Config, Settings}

  @doc """
  Run tests based on the current configuration.
  """
  @spec run(Config.t(), Settings.t(), os_type(), runner()) :: :ok | {:error, term()}
  def run(
        %Config{} = config,
        %Settings{} = settings,
        os_type \\ :os.type(),
        runner \\ &System.cmd/3
      ) do
    with {:ok, cli_args} <- Settings.cli_args(settings),
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
