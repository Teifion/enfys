defmodule Enfys.MixProject do
  use Mix.Project

  def project do
    [
      app: :enfys,
      version: "0.1.0",
      elixir: "~> 1.14",
      aliases: aliases(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Enfys.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:thousand_island, "~> 1.3"},
      {:mint, "~> 1.5"},
      {:jason, "~> 1.2"},
    ]
  end

  def aliases do
    [

    ]
  end
end
