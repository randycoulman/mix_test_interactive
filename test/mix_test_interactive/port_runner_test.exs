defmodule MixTestInteractive.PortRunnerTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.{Config, PortRunner}

  defp run(config, os_type) do
    runner = fn command, args, options ->
      send(self(), {command, args, options})
    end

    PortRunner.run(config, os_type, runner)

    receive do
      message -> message
    after
      0 -> :no_message_received
    end
  end

  describe "running on Windows" do
    defp run_windows(config \\ %Config{}) do
      run(config, {:win32, :nt})
    end

    test "runs mix test directly in test environment by default" do
      assert {"mix", ["test"], options} = run_windows()

      assert Keyword.get(options, :env) == [{"MIX_ENV", "test"}]
    end

    test "appends extra command-line arguments from config" do
      config = Config.new(["--cover"])
      {_command, args, _options} = run_windows(config)

      assert List.last(args) == "--cover"
    end

    test "uses custom task" do
      config = %Config{task: "custom"}
      assert {_command, ["custom"], _options} = run_windows(config)
    end
  end

  describe "running on Unix-like operating systems" do
    defp run_unix(config \\ %Config{}) do
      run(config, {:unix, :darwin})
    end

    test "runs mix test via zombie killer with ansi enabled in test environment by default" do
      {command, ["mix", "do", "run", "-e", ansi, ",", "test"], options} = run_unix()

      assert command =~ ~r{/zombie_killer$}
      assert ansi =~ ~r/:ansi_enabled/
      assert Keyword.get(options, :env) == [{"MIX_ENV", "test"}]
    end

    test "includes no-start flag in ansi command" do
      config = Config.new(["--no-start"])

      assert {_command, args, _options} = run_unix(config)

      assert ["mix", "do", "run", "--no-start", "-e", _ansi, ",", "test", "--no-start"] = args
    end

    test "appends extra command-line arguments from config" do
      config = Config.new(["--cover"])
      {_command, args, _options} = run_unix(config)

      assert List.last(args) == "--cover"
    end

    test "uses custom task" do
      config = %Config{task: "custom"}

      {_command, args, _options} = run_unix(config)

      assert List.last(args) == "custom"
    end
  end
end
