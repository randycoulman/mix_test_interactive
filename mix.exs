defmodule MixTestInteractive.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :mix_test_interactive,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :file_system],
      mod: {MixTestInteractive.Application, []}
    ]
  end

  defp deps do
    [
      {:file_system, "~> 0.2"},
      {:temporary_env, "~> 2.0", only: :test}
    ]
  end
end
