defmodule MixTestInteractive.MixProject do
  use Mix.Project

  @version "6.0.0"
  @source_url "https://github.com/randycoulman/mix_test_interactive"

  def project do
    [
      aliases: aliases(),
      app: :mix_test_interactive,
      deps: deps(),
      description: description(),
      docs: docs(),
      elixir: "~> 1.16",
      name: "mix test.interactive",
      package: package(),
      source_url: @source_url,
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

  def cli do
    [preferred_envs: [precommit: :test]]
  end

  defp aliases do
    [
      precommit: [
        "compile --warnings-as-errors",
        "deps.unlock --unused",
        "format",
        "docs --warnings-as-errors",
        "test"
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.40.3", only: [:dev, :test], runtime: false},
      {:file_system, "~> 0.2 or ~> 1.0"},
      {:process_tree, ">= 0.1.3"},
      {:styler, "~> 1.11", only: [:dev, :test], runtime: false},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp description do
    "Interactive test runner for mix test with watch mode."
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      formatters: ["html"],
      main: "readme",
      skip_code_autolink_to: ["MixTestInteractive.PortRunner"],
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/mix_test_interactive/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end
end
