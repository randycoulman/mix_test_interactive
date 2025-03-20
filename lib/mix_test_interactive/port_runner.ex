defmodule MixTestInteractive.PortRunner do
  @moduledoc """
  Run the tasks in a new OS process via `Port`s.

  On Unix-like operating systems, it runs the tests using a `zombie_killer` script
  as described in https://hexdocs.pm/elixir/Port.html#module-zombie-operating-system-processes.
  It also enables ANSI output mode.

  On Windows, `mix` is run directly and ANSI mode is not enabled, as it is not always
  supported by Windows command processors.
  """
  @behaviour MixTestInteractive.TestRunner

  alias MixTestInteractive.Config
  alias MixTestInteractive.TestRunner

  @application :mix_test_interactive

  @type runner ::
          (String.t(), [String.t()], keyword() ->
             {Collectable.t(), exit_status :: non_neg_integer()})

  @doc """
  Run tests based on the current configuration.
  """
  @impl TestRunner
  def run(%Config{} = config, task_args, runner \\ &System.cmd/3) do
    {command, command_args} = config.command
    task = if config.ansi_enabled?, do: enable_ansi(config.task), else: [config.task]

    {runner_program, runner_program_args} =
      case Process.get(:os_type, default: :os.type()) do
        {:win32, _} ->
          {command, command_args ++ task ++ task_args}

        _ ->
          {zombie_killer(), [command] ++ command_args ++ task ++ task_args}
      end

    runner.(runner_program, runner_program_args,
      env: [{"MIX_ENV", "test"}],
      into: IO.stream(:stdio, :line)
    )

    :ok
  end

  defp enable_ansi(task) do
    enable_command = "Application.put_env(:elixir, :ansi_enabled, true)"

    ["do", "eval", enable_command, ",", task]
  end

  defp zombie_killer do
    @application
    |> :code.priv_dir()
    |> Path.join("zombie_killer")
  end
end
