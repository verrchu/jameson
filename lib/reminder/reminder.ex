defmodule Jameson.Reminder do
  use TypedStruct

  alias __MODULE__

  typedstruct do
    field(:id, String.t(), enforce: true)
    field(:user_id, pos_integer(), enforce: true)
    field(:deadline, pos_integer(), enforce: true)
    field(:headline, String.t(), enforce: true)
    field(:description, String.t(), enforce: false)
  end

  @spec builder() :: map()
  def builder(), do: Map.new()

  @spec with_id(map(), String.t()) :: map()
  def with_id(build_data, id) do
    Map.put(build_data, :id, id)
  end

  @spec with_user_id(map(), pos_integer()) :: map()
  def with_user_id(build_data, user_id) do
    Map.put(build_data, :user_id, user_id)
  end

  @spec with_deadline(map(), pos_integer()) :: map()
  def with_deadline(build_data, deadline) do
    Map.put(build_data, :deadline, deadline)
  end

  @spec with_headline(map(), String.t()) :: map()
  def with_headline(build_data, headline) do
    Map.put(build_data, :headline, headline)
  end

  @spec with_description(map(), String.t()) :: map()
  def with_description(build_data, description) do
    Map.put(build_data, :description, description)
  end

  @spec build(map()) :: Reminder.t()
  def build(build_data) do
    reminder = %Reminder{
      id: Map.fetch!(build_data, :id),
      user_id: Map.fetch!(build_data, :user_id),
      deadline: Map.fetch!(build_data, :deadline),
      headline: Map.fetch!(build_data, :headline)
    }

    case Map.fetch(build_data, :description) do
      {:ok, description} -> %{reminder | description: description}
      :error -> reminder
    end
  end
end
