defmodule Jameson.Session.State do
  use TypedStruct

  alias __MODULE__
  alias Jameson.Reminder

  typedstruct do
    field(:chat_id, pos_integer(), enforce: true)
    field(:reminder, Reminder.t())
    field(:timer, reference())
  end

  def new(chat_id), do: %State{chat_id: chat_id}
end

defmodule Jameson.Session do
  use GenStateMachine

  use Jameson.Session.Steps

  alias __MODULE__.State
  alias __MODULE__.Registry

  require Logger

  def start_link(chat_id) do
    GenStateMachine.start_link(__MODULE__, [chat_id])
  end

  def init([chat_id]) do
    state = State.new(chat_id)
    {:ok, Steps.initial_step(), set_timer(state)}
  end

  def handle_event(:info, :timeout, step, state) do
    Logger.info("Session for chat #{state.chat_id} expired. Step: #{step}")
    {:stop, :normal, state}
  end

  def dispatch(chat_id, event) do
    {:ok, session} = Registry.get_session(chat_id)

    GenStateMachine.cast(session, {:event, event})
  end

  def set_timer(state) do
    {:ok, timeout} = Confex.fetch_env(:jameson, :session_timeout)

    unless state.timer == nil do
      Process.cancel_timer(state.timer)
    end

    timer = Process.send_after(self(), :timeout, timeout)

    %State{state | timer: timer}
  end

  def child_spec(chat_id) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [chat_id]},
      restart: :temporary
    }
  end
end
