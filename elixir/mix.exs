defmodule Resources.Mixfile do
  use Mix.Project

  def project do
    [
      app: :resources,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :poison, :httpoison]
    ]
  end

  defp deps do
    [
      {:cowboy,    git: "https://github.com/ninenines/cowboy.git"},
      {:ecto,      git: "https://github.com/elixir-ecto/ecto.git"},
      {:httpoison, git: "https://github.com/edgurgel/httpoison.git"},
      {:poison,    git: "https://github.com/devinus/poison.git", override: true},
      {:postgrex,  git: "https://github.com/elixir-ecto/postgrex.git"},
    ]
  end
end
