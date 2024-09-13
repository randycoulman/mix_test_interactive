defmodule MixTestInteractive.RunnerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  alias MixTestInteractive.Config
  alias MixTestInteractive.Runner

  defmodule DummyRunner do
    @moduledoc false
    def run(config, args) do
      Agent.get_and_update(__MODULE__, fn data -> {:ok, [{config, args} | data]} end)
    end
  end

  setup do
    {:ok, _} = Agent.start_link(fn -> [] end, name: DummyRunner)
    :ok
  end

  describe "run/1" do
    test "It delegates to the runner specified by the config" do
      config = %Config{runner: DummyRunner}
      args = ["--cover", "--raise"]

      output =
        capture_io(fn ->
          Runner.run(config, args)
        end)

      assert Agent.get(DummyRunner, fn x -> x end) == [{config, args}]

      assert output =~ "Running tests..."
    end

    test "It outputs timestamp when specified by the config" do
      config = %Config{runner: DummyRunner, show_timestamp?: true}

      output =
        capture_io(fn ->
          Runner.run(config, [])
        end)

      assert Agent.get(DummyRunner, fn x -> x end) == [{config, []}]

      timestamp =
        output
        |> String.split("\n", trim: true)
        |> List.last()

      assert {:ok, _} = NaiveDateTime.from_iso8601(timestamp)
    end
  end
end
