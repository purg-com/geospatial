defmodule Geospatial.MixProject do
  use Mix.Project

  @source_url "https://gitlab.com/mkljczk/geospatial"

  def project do
    [
      app: :geospatial,
      version: "0.2.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.4.0"},
      {:geo, "~> 3.4"},
      {:tz_world, "~> 1.0"},
      {:mox, "~> 1.0", only: :test},
      {:hackney, "~> 1.6"}
    ]
  end

  defp package() do
    [
      description:
        "This library extracts the Mobilizon.Service.Geospatial module from Mobilizon.",
      maintainers: ["Marcin Mikołajczak"],
      licenses: ["AGPL-3.0-only"],
      links: %{
        "GitLab" => @source_url
      }
    ]
  end

  defp aliases do
    [
      test: [
        "tz_world.update",
        "test"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
