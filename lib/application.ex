defmodule Jameson.Application do
  use Application

  def start(_type, _args) do
    {:ok, port} = Confex.fetch_env(:jameson, :http_port)

    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Jameson.Endpoint,
        options: [port: port]
      ),
      {Finch, name: Jameson.Finch},
      {DynamicSupervisor,
       [
         strategy: :one_for_one,
         name: Jameson.Session.Supervisor
       ]},
      {Jameson.Session.Registry, []}
      # {Jameson.Reminder.Registry, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Jameson.Supervisor)
  end
end
