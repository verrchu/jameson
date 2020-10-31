defmodule Jameson.Reminder.Registry do
  use GenServer

  require Logger

  alias Jameson.Reminder

  @jameson_reminder_registry :jameson_reminder_registry

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, get_storage_handle()}
  end

  def handle_cast({:record, reminder}, storage_handle) do
    Logger.debug("Recording reminder: #{reminder.id}")
    :ok = :dets.insert(storage_handle, {reminder.id, reminder})

    {:noreply, storage_handle}
  end

  @spec record(Reminder.t()) :: :ok
  def record(reminder) do
    GenServer.cast(__MODULE__, {:record, reminder})
  end

  def terminate(_reason, storage_handle) do
    :dets.close(storage_handle)
  end

  @spec get_storage_handle() :: atom()
  defp get_storage_handle() do
    {:ok, storage_file} = Confex.fetch_env(:jameson, :storage_file)

    {:ok, handle} =
      :dets.open_file(@jameson_reminder_registry, [
        {:file, storage_file},
        {:auto_save, :infinity}
      ])

    handle
  end
end
