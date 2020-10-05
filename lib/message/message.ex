defmodule Jameson.Message do
  def regular?(%{"message" => _msg}), do: true
  def regular?(_msg), do: false

  def get_chat_id(msg) do
    cond do
      regular?(msg) -> get_chat_id(:regular, msg)
    end
  end

  defp get_chat_id(:regular, msg) do
    %{"message" => %{"chat" => %{"id" => chat_id}}} = msg

    chat_id
  end

  def get_text(msg) do
    cond do
      regular?(msg) -> get_text(:regular, msg)
    end
  end

  defp get_text(:regular, msg) do
    %{"message" => %{"text" => text}} = msg

    text
  end
end
