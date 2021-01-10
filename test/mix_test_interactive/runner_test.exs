defmodule MixTestInteractive.RunnerTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias MixTestInteractive.Runner

  defmodule DummyRunner do
    def run() do
      Agent.get_and_update(__MODULE__, fn runs -> {:ok, runs + 1} end)
    end
  end

  setup do
    {:ok, _} = Agent.start_link(fn -> 0 end, name: DummyRunner)
    :ok
  end

  describe "running tests" do
    test "delegates to the provided runner" do
      options = [runner: DummyRunner]

      output =
        capture_io(fn ->
          Runner.run(options)
        end)

      assert Agent.get(DummyRunner, fn x -> x end) == 1

      assert output == """

             Running tests...
             """
    end
  end
end
