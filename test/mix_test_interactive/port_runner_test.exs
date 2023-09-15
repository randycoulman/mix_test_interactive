defmodule MixTestInteractive.PortRunnerTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Config
  alias MixTestInteractive.PortRunner

  defp run(os_type, options) do
    config = Keyword.get(options, :config, Config.new())
    args = Keyword.get(options, :args, [])

    runner = fn command, args, options ->
      send(self(), {command, args, options})
    end

    PortRunner.run(config, args, os_type, runner)

    receive do
      message -> message
    after
      0 -> :no_message_received
    end
  end

  describe "running on Windows" do
    defp run_windows(options \\ []) do
      run({:win32, :nt}, options)
    end

    test "runs mix test directly in test environment by default" do
      assert {"mix", ["test"], options} = run_windows()

      assert Keyword.get(options, :env) == [{"MIX_ENV", "test"}]
    end

    test "appends extra command-line arguments" do
      {_command, args, _options} = run_windows(args: ["--cover"])

      assert List.last(args) == "--cover"
    end

    test "uses custom task" do
      config = %Config{task: "custom"}
      assert {_command, ["custom"], _options} = run_windows(config: config)
    end
  end

  describe "running on Unix-like operating systems" do
    defp run_unix(options \\ []) do
      run({:unix, :darwin}, options)
    end

    test "runs mix test via zombie killer with ansi enabled in test environment by default" do
      {command, ["mix", "do", "run", "-e", ansi, ",", "test"], options} = run_unix()

      assert command =~ ~r{/zombie_killer$}
      assert ansi =~ ~r/:ansi_enabled/
      assert Keyword.get(options, :env) == [{"MIX_ENV", "test"}]
    end

    test "includes no-start flag in ansi command" do
      assert {_command, args, _options} = run_unix(args: ["--no-start"])

      assert ["mix", "do", "run", "--no-start", "-e", _ansi, ",", "test", "--no-start"] = args
    end

    test "appends extra command-line arguments from settings" do
      {_command, args, _options} = run_unix(args: ["--cover"])

      assert List.last(args) == "--cover"
    end

    test "uses custom task" do
      config = %Config{task: "custom"}

      {_command, args, _options} = run_unix(config: config)

      assert List.last(args) == "custom"
    end
  end
end
