defmodule Jameson.Session.Steps do
  alias Jameson.Message

  require Logger

  defmacro __using__(_opts) do
    steps = [
      :awaiting_command,
      :awaiting_reminder_title,
      :awaiting_reminder_timeout
    ]

    aliases =
      quote do
        alias unquote(__MODULE__)
      end

    handlers =
      for step <- steps do
        quote do
          def handle_event(:cast, {:event, event}, unquote(step) = step, state) do
            next_state = Steps.process_event(step, event, state)
            {:next_state, next_state, set_timer(state)}
          end
        end
      end

    [aliases | handlers]
  end

  @command_new "/new"
  @command_cancel "/cancel"
  @command_list "/list"

  def initial_step(), do: :awaiting_command

  def process_event(step, event, state) do
    case command?(event) do
      true -> process_command(step, event, state)
      false -> process_message(step, event, state)
    end
  end

  # ---------------------------- COMMAND NEW --------------------------------- #

  defp process_command(:awaiting_command = step, @command_new, state) do
    next_step = :awaiting_reminder_title
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  defp process_command(:awaiting_reminder_title = step, @command_new, state) do
    next_step = :awaiting_reminder_title
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  defp process_command(:awaiting_reminder_timeout = step, @command_new, state) do
    next_step = :awaiting_reminder_timeout
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  # -------------------------------------------------------------------------- #

  # ---------------------------- COMMAND CANCEL ------------------------------ #

  defp process_command(:awaiting_command = step, @command_cancel, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  defp process_command(:awaiting_reminder_title = step, @command_cancel, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  defp process_command(:awaiting_reminder_timeout = step, @command_cancel, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  # -------------------------------------------------------------------------- #

  # ----------------------------- COMMAND LIST ------------------------------- #

  defp process_command(:awaiting_command = step, @command_list, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  defp process_command(:awaiting_reminder_title = step, @command_list, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  defp process_command(:awaiting_reminder_timeout = step, @command_list, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  # -------------------------------------------------------------------------- #

  defp process_message(:awaiting_command = step, _msg, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    :awaiting_command
  end

  defp process_message(:awaiting_reminder_title = step, _msg, state) do
    next_step = :awaiting_reminder_timeout
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  defp process_message(:awaiting_reminder_timeout = step, _msg, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")
    :ok = Message.IO.send(state.chat_id, "#{step} -> #{next_step}")
    next_step
  end

  defp command?(@command_new), do: true
  defp command?(@command_cancel), do: true
  defp command?(@command_list), do: true
  defp command?(_), do: false
end
