defmodule Civo.MixProject do
  use Mix.Project

  def project do
    [
      app: :civo,
      version: "0.1.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Elixir wrapper of the Civo hosting API.",
      source_url: "https://github.com/Lazarus404/civo",
      package: package(),
      docs: [
        extras: ["README.md", "CHANGELOG.md"],
        main: "readme"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :httpoison]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:httpoison, "~> 1.6"},
      {:poison, "~> 4.0"},
      {:exvcr, "~> 0.10.4"}
    ]
  end

  defp package do
    %{
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "CHANGELOG.md"
      ],
      maintainers: ["Jahred Love"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/Lazarus404/civo"}
    }
  end
end
