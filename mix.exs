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
      extra_applications: [:logger],
      mod: {MixTestInteractive.Application, []}
    ]
  end

  defp deps do
    [
      {:temporary_env, "~> 2.0", only: :test}
    ]
  end
end
