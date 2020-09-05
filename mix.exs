defmodule Jameson.MixProject do
  use Mix.Project

  def project,
    do: [
      app: :jameson,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]

  def application,
    do: [
      extra_applications: [:logger, :confex, :ulid],
      mod: {Jameson.Application, []}
    ]

  defp deps,
    do: [
      {:confex, "~> 3.4"},
      {:typed_struct, "~> 0.2"},
      {:ulid, "~> 0.2"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
end
