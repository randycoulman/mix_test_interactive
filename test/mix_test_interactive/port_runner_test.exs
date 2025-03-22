defmodule MixTestInteractive.PortRunnerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias MixTestInteractive.Config
  alias MixTestInteractive.PortRunner

  @unix {:unix, :darwin}
  @windows {:win32, :nt}

  defp config(overrides \\ %{}) do
    Map.merge(%Config{ansi_enabled?: false}, overrides)
  end

  defp run(options \\ []) do
    case run_raw(options) do
      :no_message_received = result ->
        result

      {command, args, options} = result ->
        if command =~ ~r{/zombie_killer$} do
          [real_command | rest] = args
          {real_command, rest, options}
        else
          result
        end
    end
  end

  defp run_raw(options \\ []) do
    config = Keyword.get(options, :config, config())
    args = Keyword.get(options, :args, [])

    runner = fn command, args, options ->
      send(self(), {command, args, options})
    end

    PortRunner.run(config, args, runner)

    receive do
      message -> message
    after
      0 -> :no_message_received
    end
  end

  test "on Unix-like operating systems, runs mix test via zombie killer" do
    Process.put(:os_type, @unix)

    {command, ["mix", "test"], _options} = run_raw()

    assert command =~ ~r{/zombie_killer$}
  end

  test "on Windows, runs mix test directly" do
    Process.put(:os_type, @windows)

    assert {"mix", ["test"], _options} = run_raw()
  end

  for os_type <- [@unix, @windows] do
    describe "running on #{inspect(os_type)}" do
      setup do
        Process.put(:os_type, unquote(os_type))
        :ok
      end

      test "runs in test environment" do
        {_command, _args, options} = run()

        assert Keyword.get(options, :env) == [{"MIX_ENV", "test"}]
      end

      test "enables ansi output when turned on" do
        config = config(%{ansi_enabled?: true})
        {"mix", ["do", "eval", ansi, ",", "test"], _options} = run(config: config)

        assert ansi =~ ~r/:ansi_enabled/
      end

      test "passes no-start flag to test task" do
        assert {_command, ["test", "--no-start"], _options} = run(args: ["--no-start"])
      end

      test "appends extra command-line arguments" do
        assert {_command, ["test", "--cover"], _options} = run(args: ["--cover"])
      end

      test "uses custom task" do
        config = config(%{task: "custom_task"})
        assert {_command, ["custom_task"], _options} = run(config: config)
      end

      test "uses custom command with no args" do
        config = config(%{command: {"custom_command", []}})
        assert {"custom_command", _args, _options} = run(config: config)
      end

      test "uses custom command with args" do
        config = config(%{command: {"custom_command", ["--custom_arg"]}})
        assert {"custom_command", ["--custom_arg", "test"], _options} = run(config: config)
      end

      test "prepends command args to test args" do
        config = config(%{command: {"custom_command", ["--custom_arg"]}})

        assert {"custom_command", ["--custom_arg", "test", "--cover"], _options} =
                 run(args: ["--cover"], config: config)
      end

      test "does not display command by default" do
        {result, output} = with_io(fn -> run() end)

        assert {"mix", _args, _env} = result
        assert output == ""
      end

      test "displays command in verbose mode" do
        config = config(%{verbose?: true})

        {result, output} = with_io(fn -> run(config: config) end)

        assert {"mix", _args, _env} = result
        assert output =~ "mix test"
      end
    end
  end
end
