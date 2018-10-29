defmodule Bow.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bow,
      version: "0.2.1",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: Coverex.Task]
    ]
  end

  def application do
    [
      extra_applications: [:logger] ++ applications(Mix.env)
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp applications(:test) do
    [
      :ecto, :postgrex,     # Bow.Ecto
      :erlexec,             # Bow.Exec
      :hackney # Bow.Storage.S3
    ]
  end
  defp applications(_), do: []

  defp deps do
    [
      {:plug,     "~> 1.0"},
      {:httpoison, "~> 1.4"},

      {:ecto,       ">= 2.0.0 and < 3.0.0", optional: true},
      {:erlexec,    "~> 1.9.0", optional: true},
      {:ex_aws,     "~> 2.0", optional: true},
      {:ex_aws_s3,  "~> 2.0", optional: true},

      # testing & docs
      {:postgrex,       ">= 0.0.0",  only: :test},
      {:coverex,        "~> 1.4.10", only: :test},
      {:mock,           "~> 0.3.0",  only: :test},
      {:ex_doc,         "~> 0.16.1", only: :dev},
      {:mix_test_watch, "~> 0.5.0",  only: :dev},
      {:dialyxir,       "~> 0.5.1",  only: :dev}
    ]
  end

  def aliases do
    ["ecto.setup": ["ecto.create --quiet", "ecto.migrate --quiet"],
     "ecto.reset": ["ecto.drop --quiet", "ecto.setup"]]
  end
end
