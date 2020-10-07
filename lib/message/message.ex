defmodule Jameson.Message do
  @type message() :: map()
  @type message_type() :: :regular

  @spec regular?(message()) :: boolean()
  def regular?(%{"message" => _msg}), do: true
  def regular?(_msg), do: false

  @spec get_chat_id(message()) :: integer()
  def get_chat_id(msg) do
    cond do
      regular?(msg) -> get_chat_id(:regular, msg)
    end
  end

  @spec get_chat_id(message_type(), message()) :: integer()
  defp get_chat_id(:regular, msg) do
    %{"message" => %{"chat" => %{"id" => chat_id}}} = msg

    chat_id
  end

  @spec get_text(message()) :: String.t()
  def get_text(msg) do
    cond do
      regular?(msg) -> get_text(:regular, msg)
    end
  end

  @spec get_text(message_type(), message()) :: String.t()
  defp get_text(:regular, msg) do
    %{"message" => %{"text" => text}} = msg

    text
  end
end
