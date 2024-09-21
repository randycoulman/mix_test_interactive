defmodule MixTestInteractive.TestRunner do
  @moduledoc """
  Behaviour for custom test runners.

  Any custom runner defined in the configuration or by command-line options must
  implement this behaviour, either explicitly or implicitly.
  """
  alias MixTestInteractive.Config

  @callback run(Config.t(), [String.t()]) :: :ok
end
