defmodule Jameson.DB.State do
  use TypedStruct

  alias __MODULE__

  typedstruct do
    field(:cache_handle, atom(), enforce: true)
    field(:db_handle, atom(), enforce: true)
  end

  @spec builder() :: map()
  def builder(), do: Map.new()

  @spec with_cache_handle(map(), atom()) :: map()
  def with_cache_handle(build_data, handle) do
    Map.put(build_data, :cache_handle, handle)
  end

  @spec with_db_handle(map(), atom()) :: map()
  def with_db_handle(build_data, handle) do
    Map.put(build_data, :db_handle, handle)
  end

  @spec build(map()) :: State.t()
  def build(build_data) do
    %State{
      cache_handle: Map.fetch!(build_data, :cache_handle),
      db_handle: Map.fetch!(build_data, :db_handle)
    }
  end
end

defmodule Jameson.DB.Row do
  use TypedStruct

  alias __MODULE__

  @type lang :: :ru

  typedstruct do
    field(:lang, lang())
  end

  @spec new() :: Row.t()
  def new(), do: %Row{}

  @spec with_language(Row.t(), lang()) :: Row.t()
  def with_language(row, lang), do: %{row | lang: lang}
end

defmodule Jameson.DB do
  use GenServer

  require Logger

  alias __MODULE__
  alias __MODULE__.State

  @jameson_db_cache :jameson_db_cache
  @jameson_db :jameson_db

  def set_language(chat_id, lang) do
    GenServer.cast(__MODULE__, {:set_language, chat_id, lang})
  end

  def get_language(chat_id) do
    GenServer.call(__MODULE__, {:get_language, chat_id})
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, cache_handle} = get_cache_handle()
    {:ok, db_handle} = get_db_handle()

    :ok = populate_cache(cache_handle, db_handle)

    state =
      State.builder()
      |> State.with_cache_handle(cache_handle)
      |> State.with_db_handle(db_handle)
      |> State.build()

    {:ok, state}
  end

  def handle_cast({:set_language, chat_id, language}, state) do
    :ok =
      get_row(chat_id, {state.db_handle, state.cache_handle})
      |> DB.Row.with_language(language)
      |> insert_row(chat_id, {state.db_handle, state.cache_handle})

    {:noreply, state}
  end

  def handle_call({:get_language, chat_id}, _from, state) do
    row = get_row(chat_id, {state.db_handle, state.cache_handle})

    case row.lang == nil do
      true -> {:reply, :not_found, state}
      false -> {:reply, row.lang, state}
    end
  end

  defp insert_row(row, chat_id, {db_handle, cache_handle}) do
    :ok = :dets.insert(db_handle, {chat_id, row})
    :ets.insert(cache_handle, {chat_id, row})

    :ok
  end

  defp get_row(chat_id, {db_handle, cache_handle}) do
    case :ets.lookup(cache_handle, chat_id) do
      [] ->
        case :dets.lookup(db_handle, chat_id) do
          [] ->
            DB.Row.new()

          [{^chat_id, row} = record] ->
            :ets.insert(cache_handle, record)
            row
        end

      [{^chat_id, row}] ->
        row
    end
  end

  def terminate(_reason, state) do
    :dets.close(state.db_handle)
  end

  @spec populate_cache(atom(), atom()) :: :ok
  defp populate_cache(cache_handle, db_handle) do
    true = :ets.from_dets(cache_handle, db_handle)

    :ok
  end

  @spec get_cache_handle() :: {:ok, atom()}
  defp get_cache_handle() do
    handle =
      :ets.new(@jameson_db_cache, [
        :public,
        :named_table
      ])

    {:ok, handle}
  end

  @spec get_db_handle() :: {:ok, atom()}
  defp get_db_handle() do
    {:ok, db_file} = Confex.fetch_env(:jameson, :db_file)

    {:ok, handle} =
      :dets.open_file(@jameson_db, [
        {:file, db_file},
        {:auto_save, :infinity}
      ])

    {:ok, handle}
  end
end
