defmodule MixTestInteractive.EndToEndTest do
  use ExUnit.Case, async: true

  alias MixTestInteractive.Config
  alias MixTestInteractive.InteractiveMode
  alias MixTestInteractive.Settings

  defmodule DummyRunner do
    @moduledoc false
    def run(config, args) do
      Agent.update(__MODULE__, fn test_pid ->
        send(test_pid, {config, args})
        test_pid
      end)
    end
  end

  @config %Config{runner: DummyRunner}
  @settings Settings.new([])

  setup do
    test_pid = self()
    {:ok, _} = Agent.start_link(fn -> test_pid end, name: DummyRunner)

    {:ok, io} = StringIO.open("")
    Process.group_leader(self(), io)

    {:ok, pid} = start_supervised({InteractiveMode, config: @config, name: :end_to_end, settings: @settings})
    %{pid: pid}
  end

  test "end to end workflow test", %{pid: pid} do
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

    assert :ok = InteractiveMode.process_command(pid, "w")
    refute_ran_tests()

    assert :ok = InteractiveMode.note_file_changed(pid)
    refute_ran_tests()

    assert :ok = InteractiveMode.process_command(pid, "w")
    refute_ran_tests()

    assert :ok = InteractiveMode.note_file_changed(pid)
    assert_ran_tests(["--stale"])
  end

  defp assert_ran_tests(args \\ []) do
    assert_receive {@config, ^args}, 100
  end

  defp refute_ran_tests do
    refute_receive _, 100
  end
end
