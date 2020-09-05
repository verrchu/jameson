defmodule Jameson.Registry.State do
  use TypedStruct

  alias __MODULE__

  typedstruct do
    field(:cache_handle, atom(), enforce: true)
    field(:storage_handle, atom(), enforce: true)
  end

  @spec builder() :: map()
  def builder(), do: Map.new()

  @spec with_cache_handle(map(), atom()) :: map()
  def with_cache_handle(build_data, handle) do
    Map.put(build_data, :cache_handle, handle)
  end

  @spec with_storage_handle(map(), atom()) :: map()
  def with_storage_handle(build_data, handle) do
    Map.put(build_data, :storage_handle, handle)
  end

  @spec build(map()) :: State.t()
  def build(build_data) do
    %State{
      cache_handle: Map.fetch!(build_data, :cache_handle),
      storage_handle: Map.fetch!(build_data, :storage_handle)
    }
  end
end

defmodule Jameson.Registry do
  use GenServer

  require Logger

  alias __MODULE__.State
  alias Jameson.Reminder

  @jameson_registry_cache :jameson_registry_cache
  @jameson_registry_storage :jameson_registry_storage

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, cache_handle} = get_cache_handle()
    {:ok, storage_handle} = get_storage_handle()

    state =
      State.builder()
      |> State.with_cache_handle(cache_handle)
      |> State.with_storage_handle(storage_handle)
      |> State.build()

    {:ok, state, {:continue, :set_check_timer}}
  end

  def handle_continue(:set_check_timer, state) do
    {:ok, _ref} = set_check_timer()
    {:noreply, state}
  end

  def handle_info(:check, state) do
    {:noreply, state, {:continue, :set_check_timer}}
  end

  def handle_cast({:record, reminder}, state) do
    :ok = record_reminder({:cache, state.cache_handle}, reminder)
    :ok = record_reminder({:storage, state.storage_handle}, reminder)

    {:noreply, state}
  end

  @spec record(Reminder.t()) :: :ok
  def record(reminder) do
    GenServer.cast(__MODULE__, {:record, reminder})
  end

  def terminate(_reason, state) do
    :dets.close(state.storage_handle)
  end

  @spec get_cache_handle() :: {:ok, atom()}
  defp get_cache_handle() do
    handle =
      :ets.new(@jameson_registry_cache, [
        :bag,
        :public,
        :named_table
      ])

    {:ok, handle}
  end

  @spec get_storage_handle() :: {:ok, atom()}
  defp get_storage_handle() do
    {:ok, storage_file} = Confex.fetch_env(:jameson, :storage_file)

    {:ok, handle} =
      :dets.open_file(@jameson_registry_storage, [
        {:type, :bag},
        {:file, storage_file},
        {:auto_save, :infinity}
      ])

    {:ok, handle}
  end

  @spec record_reminder({:cache | :storage, atom()}, Reminder.t()) :: :ok
  defp record_reminder({:cache, handle}, reminder) do
    true = :ets.insert(handle, {reminder.deadline, reminder.id})

    :ok
  end

  defp record_reminder({:storage, handle}, reminder) do
    :ok = :dets.insert(handle, {reminder.id, reminder.user_id, reminder})

    :ok
  end

  @spec set_check_timer() :: {:ok, reference()}
  defp set_check_timer() do
    {:ok, check_interval} = Confex.fetch_env(:jameson, :check_interval)
    Logger.debug("Setting check timer for #{check_interval} milliseconds")

    ref = Process.send_after(self(), :check, check_interval)
    {:ok, ref}
  end
end
