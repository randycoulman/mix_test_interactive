defmodule MixTestInteractive.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :mix_test_interactive,
      deps: deps(),
      docs: docs(),
      elixir: "~> 1.8",
      name: "mix test.interactive",
      source_url: "https://github.com/influxdata/mix_test_interactive",
      start_permanent: Mix.env() == :prod,
      version: @version
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
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:file_system, "~> 0.2"},
      {:temporary_env, "~> 2.0", only: :test},
      {:typed_struct, "~> 0.2.1"}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      groups_for_modules: [
        Commands: [~r/^MixTestInteractive\.Command\..*/]
      ],
      main: "readme"
    ]
  end
end
