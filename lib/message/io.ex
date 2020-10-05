defmodule Jameson.Message.IO do
  require Logger

  alias Jameson.Message
  alias Jameson.Session

  @api_endpoint "https://api.telegram.org:443"

  defp api_endpoint() do
    {:ok, api_key} = Confex.fetch_env(:jameson, :api_key)

    "#{@api_endpoint}/bot#{api_key}/sendMessage"
  end

  def receive(msg) do
    chat_id = Message.get_chat_id(msg)
    text = Message.get_text(msg)

    Session.dispatch(chat_id, text)
  end

  def send(chat_id, text) do
    body = %{"chat_id" => chat_id, "text" => text} |> Jason.encode!()
    headers = [{"Content-Type", "application/json"}]
    Finch.build(:post, api_endpoint(), headers, body) |> Finch.request(Jameson.Finch)

    :ok
  end
end
