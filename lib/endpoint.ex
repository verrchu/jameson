defmodule Jameson.Endpoint do
  use Plug.Router

  require Logger

  alias Jameson.Message

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/ping" do
    send_resp(conn, 200, "pong")
  end

  post "/notify" do
    Message.In.receive(conn.body_params)
    send_resp(conn, 200, "ok")
  end
end
