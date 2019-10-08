defmodule Civo.MixProject do
  use Mix.Project

  def project do
    [
      app: :civo,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
end
