defmodule BettyPoker.MixProject do
  use Mix.Project

  def project do
    [
      app: :betty_poker,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dialyxer - static analysis
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},

      # Credo - Linting code
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:credo_envvar, "~> 0.1.4", only: [:dev, :test], runtime: false},
      {:credo_naming, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
