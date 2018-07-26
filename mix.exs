defmodule Graveyard.Mixfile do
  use Mix.Project

  def project do
    [
      app: :graveyard,
      version: "0.2.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      elixirc_path: elixirc_path(Mix.env),
      description: description(),
      source_url: github(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :timex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tirexs, "~> 0.8"},
      {:faker, "~> 0.10", only: :test},
      {:timex, "~> 3.1"},
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

  defp elixirc_path(:test), do: ["lib", "test/support"]
  defp elixirc_path(_), do: ["lib"]
end
