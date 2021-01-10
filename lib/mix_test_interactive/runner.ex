defmodule MixTestInteractive.Runner do
  @moduledoc false

  alias MixTestInteractive.PortRunner

  @type option :: {:runner, module()}

  @doc """
  Run tests using provided runner.
  """
  @spec run([option]) :: :ok
  def run(opts \\ []) do
    runner = Keyword.get(opts, :runner, PortRunner)
    IO.puts("\nRunning tests...")
    runner.run()
  end
end
