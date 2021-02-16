defmodule MixTestInteractive.RunnerTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias MixTestInteractive.{Config, Runner, Settings}

  defmodule DummyRunner do
    def run(config, settings) do
      Agent.get_and_update(__MODULE__, fn data -> {:ok, [{config, settings} | data]} end)
    end
  end

  setup do
    {:ok, _} = Agent.start_link(fn -> [] end, name: DummyRunner)
    :ok
  end

  describe "run/1" do
    test "It delegates to the runner specified by the config" do
      config = %Config{runner: DummyRunner}
      settings = Settings.new()

      output =
        capture_io(fn ->
          Runner.run(config, settings)
        end)

      assert Agent.get(DummyRunner, fn x -> x end) == [{config, settings}]

      assert output == """

             Running tests...
             """
    end

    test "It outputs timestamp when specified by the config" do
      config = %Config{runner: DummyRunner, show_timestamp?: true}
      settings = Settings.new()

      output =
        capture_io(fn ->
          Runner.run(config, settings)
        end)

      assert Agent.get(DummyRunner, fn x -> x end) == [{config, settings}]

      timestamp =
        output
        |> String.replace_leading(
          """

          Running tests...
          """,
          ""
        )
        |> String.trim()

      assert {:ok, _} = NaiveDateTime.from_iso8601(timestamp)
    end
  end
end
