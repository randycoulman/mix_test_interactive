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

  alias MixTestInteractive.Config

  @doc """
  Run tests based on the current configuration.
  """
  @spec run(Config.t(), [String.t()], os_type(), runner()) :: :ok
  def run(
        %Config{} = config,
        args,
        os_type \\ :os.type(),
        runner \\ &System.cmd/3
      ) do
    task_command = [config.task | args]
    do_commands = config.before_task ++ [task_command] ++ config.after_task

    case os_type do
      {:win32, _} ->
        runner.("mix", flatten_do_commands(do_commands),
          env: [{"MIX_ENV", "test"}],
          into: IO.stream(:stdio, :line)
        )

      _ ->
        do_commands = [enable_ansi(task_command) | do_commands]

        Path.join(:code.priv_dir(@application), "zombie_killer")
        |> runner.(["mix" | flatten_do_commands(do_commands)],
          env: [{"MIX_ENV", "test"}],
          into: IO.stream(:stdio, :line)
        )
    end

    :ok
  end

  defp enable_ansi(task_command) do
    enable_command = "Application.put_env(:elixir, :ansi_enabled, true);"

    if Enum.member?(task_command, "--no-start") do
      ["run", "--no-start", "-e", enable_command]
    else
      ["run", "-e", enable_command]
    end
  end

  defp flatten_do_commands(do_commands) do
    commands =
      do_commands
      |> Enum.reject(&(&1 == []))
      |> Enum.intersperse([","])
      |> Enum.concat()

    ["do" | commands]
  end
end
