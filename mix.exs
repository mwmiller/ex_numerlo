defmodule ExNumerlo.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_numerlo,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      name: "ExNumerlo",
      source_url: "https://github.com/mwmiller/ex_numerlo"
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      precommit: ["format --check-formatted", "credo --strict", "test"]
    ]
  end

  defp description do
    "A library for rendering integers using various Unicode numeral systems."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mwmiller/ex_numerlo"},
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE usage-rules.md)
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.37", runtime: false},
      {:stream_data, "~> 1.1", only: :test},
      {:usage_rules, "~> 1.0", only: [:dev]},
      {:igniter, "~> 0.6", only: [:dev]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
