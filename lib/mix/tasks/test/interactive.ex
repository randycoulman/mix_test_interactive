defmodule Mix.Tasks.Test.Interactive do
  use Mix.Task

  @moduledoc """
  A task for interactively running tests
  """

  @shortdoc "Interactively run tests"
  @preferred_cli_env :test

  defdelegate run(args), to: MixTestInteractive
end
