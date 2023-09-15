defmodule Mix.Tasks.Test.Interactive do
  @shortdoc "Interactively run tests"
  @moduledoc """
  A task for interactively running tests
  """

  use Mix.Task

  @preferred_cli_env :test

  defdelegate run(args), to: MixTestInteractive
end
