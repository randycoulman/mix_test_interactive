defmodule MixTestInteractive.PortRunnerTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Config
  alias MixTestInteractive.PortRunner

  defp run(os_type, options) do
    config = Keyword.get(options, :config, %Config{})
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
      assert {"mix", ["test", "--cover"], _options} = run_windows(args: ["--cover"])
    end

    test "uses custom task" do
      config = %Config{task: "custom"}
      assert {_command, ["custom"], _options} = run_windows(config: config)
    end

    test "uses custom command with no args" do
      config = %Config{command: {"custom_command", []}}
      assert {"custom_command", _args, _options} = run_windows(config: config)
    end

    test "uses custom command with args" do
      config = %Config{command: {"custom_command", ["--custom_arg"]}}
      assert {"custom_command", ["--custom_arg", "test"], _options} = run_windows(config: config)
    end

    test "prepends command args to test args" do
      config = %Config{command: {"custom_command", ["--custom_arg"]}}

      assert {"custom_command", ["--custom_arg", "test", "--cover"], _options} =
               run_windows(args: ["--cover"], config: config)
    end
  end

  describe "running on Unix-like operating systems" do
    defp run_unix(options \\ []) do
      run({:unix, :darwin}, options)
    end

    test "runs mix test via zombie killer with ansi enabled in test environment by default" do
      {command, ["mix", "do", "eval", ansi, ",", "test"], options} = run_unix()

      assert command =~ ~r{/zombie_killer$}
      assert ansi =~ ~r/:ansi_enabled/
      assert Keyword.get(options, :env) == [{"MIX_ENV", "test"}]
    end

    test "passes no-start flag to test task" do
      assert {_command, args, _options} = run_unix(args: ["--no-start"])

      assert ["mix", "do", "eval", _ansi, ",", "test", "--no-start"] = args
    end

    test "appends extra command-line arguments from settings" do
      {_command, args, _options} = run_unix(args: ["--cover"])

      assert ["mix", "do", "eval", _ansi, ",", "test", "--cover"] = args
    end

    test "uses custom task" do
      config = %Config{task: "custom_task"}

      {_command, args, _options} = run_unix(config: config)

      assert ["mix", "do", "eval", _ansi, ",", "custom_task"] = args
    end

    test "uses custom command with no args" do
      config = %Config{command: {"custom_command", []}}

      {_command, args, _options} = run_unix(config: config)

      assert ["custom_command", "do", "eval", _ansi, ",", "test"] = args
    end

    test "uses custom command with args" do
      config = %Config{command: {"custom_command", ["--custom_arg"]}}

      {_command, args, _options} = run_unix(config: config)

      assert ["custom_command", "--custom_arg", "do", "eval", _ansi, ",", "test"] = args
    end

    test "prepends command args to test args" do
      config = %Config{command: {"custom_command", ["--custom_arg"]}}

      {_command, args, _options} = run_unix(args: ["--cover"], config: config)

      assert ["custom_command", "--custom_arg", "do", "eval", _ansi, ",", "test", "--cover"] = args
    end
  end
end
