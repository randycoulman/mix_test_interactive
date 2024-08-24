defmodule MixTestInteractive.PortRunner do
  @moduledoc """
  Run the tasks in a new OS process via `Port`s.

  On Unix-like operating systems, it runs the tests using a `zombie_killer` script
  as described in https://hexdocs.pm/elixir/Port.html#module-zombie-operating-system-processes.
  It also enables ANSI output mode.

  On Windows, `mix` is run directly and ANSI mode is not enabled, as it is not always
  supported by Windows command processors.
  """

  alias MixTestInteractive.Config

  @application :mix_test_interactive

  @type runner ::
          (String.t(), [String.t()], keyword() ->
             {Collectable.t(), exit_status :: non_neg_integer()})
  @type os_type :: {atom(), atom()}

  @doc """
  Run tests based on the current configuration.
  """
  @spec run(Config.t(), [String.t()], os_type(), runner()) :: :ok
  def run(%Config{} = config, args, os_type \\ :os.type(), runner \\ &System.cmd/3) do
    {command, extra_args} = config.command
    args = extra_args ++ [config.task | args]

    case os_type do
      {:win32, _} ->
        runner.(command, args,
          env: [{"MIX_ENV", "test"}],
          into: IO.stream(:stdio, :line)
        )

      _ ->
        args = enable_ansi(args)

        @application
        |> :code.priv_dir()
        |> Path.join("zombie_killer")
        |> runner.([command | args],
          env: [{"MIX_ENV", "test"}],
          into: IO.stream(:stdio, :line)
        )
    end

    :ok
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
