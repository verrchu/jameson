defmodule Jameson.Session.State do
  use TypedStruct

  alias __MODULE__
  alias Jameson.Reminder
  alias Jameson.Types

  typedstruct do
    field(:chat_id, pos_integer(), enforce: true)
    field(:lang, Types.lang())
    field(:reminder, Reminder.t())
    field(:timer, reference())
  end

  @spec new(pos_integer()) :: State.t()
  def new(chat_id), do: %State{chat_id: chat_id, reminder: Reminder.new()}

  @spec with_lang(State.t(), Types.lang()) :: State.t()
  def with_lang(state, lang), do: %State{state | lang: lang}

  @spec with_reminder(State.t(), Reminder.t()) :: State.t()
  def with_reminder(state, reminder), do: %State{state | reminder: reminder}
end

defmodule Jameson.Session do
  use GenStateMachine

  alias __MODULE__.State
  alias __MODULE__.Registry
  alias __MODULE__.Steps

  require Logger

  def start_link(chat_id) do
    GenStateMachine.start_link(__MODULE__, [chat_id])
  end

  def init([chat_id]) do
    state = State.new(chat_id)
    {:ok, :awaiting_command, set_timer(state)}
  end

  def handle_event(:cast, {:event, event}, :awaiting_command = step, state) do
    {next_step, new_state} = Steps.process_event(step, event, state)
    {:next_state, next_step, set_timer(new_state)}
  end

  def handle_event(:cast, {:event, event}, :awaiting_reminder_title = step, state) do
    {next_step, new_state} = Steps.process_event(step, event, state)
    {:next_state, next_step, set_timer(new_state)}
  end

  def handle_event(:cast, {:event, event}, :awaiting_reminder_timeout = step, state) do
    {next_step, new_state} = Steps.process_event(step, event, state)
    {:next_state, next_step, set_timer(new_state)}
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
