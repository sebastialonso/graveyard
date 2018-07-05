defmodule Graveyard.Mixfile do
  use Mix.Project

  def project do
    [
      app: :graveyard,
      version: "0.1.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      source_url: github(),
      package: package()
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
      {:tirexs, "~> 0.8"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    A teeny-tiny ORM/library for managing ElasticSearch documents in Elixir
    """
  end

  defp github do
    "https://github.com/sebastialonso/graveyard"
  end

  defp package() do
    [
      maintainers: ["Sebastián González"],
      licenses: ["MIT"],
      links: %{
        "Github" => github()
      },
      files: ["lib", "test", "mix.exs"]
    ]
  end
end
