defmodule MixTestInteractive.EndToEndTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Config
  alias MixTestInteractive.InteractiveMode
  alias MixTestInteractive.Settings

  defmodule DummyRunner do
    @moduledoc false
    @behaviour MixTestInteractive.TestRunner

    use Agent

    alias MixTestInteractive.TestRunner

    def start_link(test_pid) do
      Agent.start_link(fn -> test_pid end, name: __MODULE__)
    end

    @impl TestRunner
    def run(config, args) do
      Agent.update(__MODULE__, fn test_pid ->
        send(test_pid, {config, args})
        test_pid
      end)

      :ok
    end
  end

  @config %Config{runner: DummyRunner}
  @settings %Settings{}

  setup do
    {:ok, io} = StringIO.open("")
    Process.group_leader(self(), io)

    _pid = start_supervised!({DummyRunner, self()})
    pid = start_supervised!({InteractiveMode, config: @config, name: :end_to_end, settings: @settings})

    %{pid: pid}
  end

  test "failed/stale/pattern workflow", %{pid: pid} do
    assert_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "")
    assert_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "p test_file:42")
    assert_ran_tests(["test_file:42"])

    assert :ok = InteractiveMode.process_command(pid, "f")
    assert_ran_tests(["--failed"])

    assert :ok = InteractiveMode.process_command(pid, "a")
    assert_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "s")
    assert_ran_tests(["--stale"])

    assert :ok = InteractiveMode.note_file_changed(pid)
    assert_ran_tests(["--stale"])
  end

  test "max failures workflow", %{pid: pid} do
    assert_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "m 3")
    assert_ran_tests(["--max-failures", "3"])

    assert :ok = InteractiveMode.process_command(pid, "m")
    assert_ran_tests()
  end

  test "seed workflow", %{pid: pid} do
    assert_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "d 4242")
    assert_ran_tests(["--seed", "4242"])

    assert :ok = InteractiveMode.note_file_changed(pid)
    assert_ran_tests(["--seed", "4242"])

    assert :ok = InteractiveMode.process_command(pid, "s")
    assert_ran_tests(["--seed", "4242", "--stale"])

    assert :ok = InteractiveMode.process_command(pid, "d")
    assert_ran_tests(["--stale"])
  end

  test "tag workflow", %{pid: pid} do
    assert_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "i tag1 tag2")
    assert_ran_tests(["--include", "tag1", "--include", "tag2"])

    assert :ok = InteractiveMode.process_command(pid, "o tag3")
    assert_ran_tests(["--include", "tag1", "--include", "tag2", "--only", "tag3"])

    assert :ok = InteractiveMode.process_command(pid, "x tag4 tag5")

    assert_ran_tests([
      "--exclude",
      "tag4",
      "--exclude",
      "tag5",
      "--include",
      "tag1",
      "--include",
      "tag2",
      "--only",
      "tag3"
    ])

    assert :ok = InteractiveMode.process_command(pid, "o")
    assert_ran_tests(["--exclude", "tag4", "--exclude", "tag5", "--include", "tag1", "--include", "tag2"])

    assert :ok = InteractiveMode.process_command(pid, "i")
    assert_ran_tests(["--exclude", "tag4", "--exclude", "tag5"])

    assert :ok = InteractiveMode.process_command(pid, "x")
    assert_ran_tests()
  end

  test "trace on/off workflow", %{pid: pid} do
    assert_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "t")
    assert_ran_tests(["--trace"])

    assert :ok = InteractiveMode.process_command(pid, "t")
    assert_ran_tests()
  end

  test "watch on/off workflow", %{pid: pid} do
    assert_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "w")
    refute_ran_tests()

    assert :ok = InteractiveMode.note_file_changed(pid)
    refute_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "w")
    refute_ran_tests()

    assert :ok = InteractiveMode.note_file_changed(pid)
    assert_ran_tests()
  end

  defp assert_ran_tests(args \\ []) do
    assert_receive {@config, ^args}, 100
  end

  defp refute_ran_tests do
    refute_receive _, 100
  end
end
