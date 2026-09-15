defmodule Civo.MixProject do
  use Mix.Project

  @version "1.0.0"
  @source_url "https://github.com/Lazarus404/civo"

  def project do
    [
      app: :civo,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Civo",
      source_url: @source_url,
      homepage_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger, :httpoison]
    ]
  end

  defp description do
    "Elixir client for the Civo cloud API (https://api.civo.com/v2)."
  end

  defp deps do
    [
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"},
      {:exvcr, "~> 0.15", only: :test}
    ]
  end

  defp package do
    [
      name: "civo",
      files: ~w(lib mix.exs README.md CHANGELOG.md LICENSE .formatter.exs assets),
      maintainers: ["Jahred Love"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "Civo API" => "https://www.civo.com/api"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "LICENSE"],
      source_ref: "v#{@version}",
      source_url: @source_url,
      assets: %{"assets" => "assets"}
    ]
  end
end
