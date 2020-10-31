defmodule Jameson.Reminder do
  use TypedStruct

  alias __MODULE__

  typedstruct do
    field(:id, String.t(), enforce: true)
    field(:chat_id, pos_integer())
    field(:timeout, pos_integer())
    field(:title, String.t())
  end

  @spec new() :: Reminder.t()
  def new(), do: %Reminder{id: Ulid.generate()}

  @spec with_id(Reminder.t(), String.t()) :: Reminder.t()
  def with_id(reminder, id), do: %{reminder | id: id}

  @spec with_chat_id(Reminder.t(), pos_integer()) :: Reminder.t()
  def with_chat_id(reminder, chat_id), do: %{reminder | chat_id: chat_id}

  @spec with_timeout(Reminder.t(), pos_integer()) :: Reminder.t()
  def with_timeout(reminder, timeout), do: %{reminder | timeout: timeout}

  @spec with_title(Reminder.t(), String.t()) :: Reminder.t()
  def with_title(reminder, title), do: %{reminder | title: title}
end
