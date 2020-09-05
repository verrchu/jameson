defmodule Jameson.Application do
  use Application

  def start(_type, _args) do
    children = [{Jameson.Registry, []}]

    Supervisor.start_link(children, strategy: :one_for_one, name: Jameson.Supervisor)
  end
end
