defmodule Jameson.Message.In do
  @type message() :: map()
  @type message_type() :: :regular | :callback

  alias Jameson.Session

  @spec regular?(message()) :: boolean()
  def regular?(%{"message" => _msg}), do: true
  def regular?(_msg), do: false

  @spec callback?(message()) :: boolean()
  def callback?(%{"callback_query" => _msg}), do: true
  def callback?(_msg), do: false

  def receive(msg) do
    cond do
      regular?(msg) ->
        chat_id = get_chat_id(:regular, msg)

        text = get_text(msg)

        Session.dispatch(chat_id, {:regular, text})

      callback?(msg) ->
        chat_id = get_chat_id(:callback, msg)

        cb_data = get_cb_data(msg)
        cb_id = get_cb_id(msg)

        Session.dispatch(chat_id, {:callback, cb_id, cb_data})
    end
  end

  @spec get_chat_id(message_type(), message()) :: integer()
  defp get_chat_id(:regular, msg) do
    %{"message" => %{"from" => %{"id" => chat_id}}} = msg

    chat_id
  end

  defp get_chat_id(:callback, msg) do
    %{"callback_query" => %{"from" => %{"id" => chat_id}}} = msg

    chat_id
  end

  @spec get_text(message()) :: String.t()
  defp get_text(msg) do
    %{"message" => %{"text" => text}} = msg

    text
  end

  @spec get_cb_data(message()) :: String.t()
  defp get_cb_data(msg) do
    %{"callback_query" => %{"data" => cb_data}} = msg

    cb_data
  end

  @spec get_cb_id(message()) :: String.t()
  defp get_cb_id(msg) do
    %{"callback_query" => %{"id" => cb_id}} = msg

    cb_id
  end
end
