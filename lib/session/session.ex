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

  alias __MODULE__.State
  alias __MODULE__.Registry

  alias Jameson.Message

  require Logger

  @step_awaiting_command :awaiting_command

  def start_link(chat_id) do
    GenStateMachine.start_link(__MODULE__, [chat_id])
  end

  def init([chat_id]) do
    state = State.new(chat_id)
    {:ok, @step_awaiting_command, set_timer(state)}
  end

  def handle_event(:cast, {:msg, msg}, @step_awaiting_command, state) do
    :ok = Message.IO.send(state.chat_id, msg)
    {:next_state, @step_awaiting_command, set_timer(state)}
  end

  def handle_event(:info, :timeout, step, state) do
    Logger.info("Session for chat #{state.chat_id} expired. Step: #{step}")
    {:stop, :normal, state}
  end

  def dispatch(chat_id, msg) do
    {:ok, session} = Registry.get_session(chat_id)

    GenStateMachine.cast(session, {:msg, msg})
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
