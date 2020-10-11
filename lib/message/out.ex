defmodule Jameson.Message.Out do
  use TypedStruct

  alias Jameson.Message

  @api_endpoint "https://api.telegram.org:443"
  @api_send_message "/sendMessage"
  @api_answer_callback_query "/answerCallbackQuery"

  defp api_endpoint(api) do
    {:ok, api_key} = Confex.fetch_env(:jameson, :api_key)

    "#{@api_endpoint}/bot#{api_key}#{api}"
  end

  typedstruct do
    field(:text, String.t(), enforce: true)
    field(:buttons, [{String.t(), String.t()}])
  end

  @spec new(String.t()) :: Message.Out.t()
  def new(text), do: %__MODULE__{text: text}

  @spec with_buttons(Message.Out.t(), [{String.t(), String.t()}]) :: Message.Out.t()
  def with_buttons(msg, buttons), do: %__MODULE__{msg | buttons: buttons}

  @spec send(Message.Out.t(), integer()) :: :ok
  def send(msg, chat_id) do
    body =
      if msg.buttons do
        buttons =
          Enum.map(msg.buttons, fn {text, cb_data} ->
            %{"text" => text, "callback_data" => cb_data}
          end)

        %{
          "chat_id" => chat_id,
          "text" => msg.text,
          "reply_markup" => %{
            "inline_keyboard" => [buttons]
          }
        }
      else
        %{"chat_id" => chat_id, "text" => msg.text}
      end

    headers = [{"Content-Type", "application/json"}]

    Finch.build(
      :post,
      api_endpoint(@api_send_message),
      headers,
      Jason.encode!(body)
    )
    |> Finch.request(Jameson.Finch)

    :ok
  end

  @spec callback(Message.Out.t(), integer()) :: :ok
  def callback(msg, cb_id) do
    body = %{"callback_query_id" => cb_id, "text" => msg.text}

    headers = [{"Content-Type", "application/json"}]

    Finch.build(
      :post,
      api_endpoint(@api_answer_callback_query),
      headers,
      Jason.encode!(body)
    )
    |> IO.inspect()
    |> Finch.request(Jameson.Finch)
    |> IO.inspect()

    :ok
  end
end
