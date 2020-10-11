defmodule Jameson.Session.Steps do
  alias Jameson.Message
  alias Jameson.Session
  alias Jameson.DB
  alias Jameson.Types
  alias Jameson.Config

  require Logger

  @command_new "/new"
  @command_cancel "/cancel"
  @command_list "/list"
  @command_settings "/settings"

  @callback_setting_set "/setting_set"

  @setting_language "language"

  @spec process_event(Types.session_step(), String.t(), Session.State.t()) ::
          {Types.session_step(), Session.State.t()}
  def process_event(step, event, state) do
    case language_set?(state) do
      {true, state} ->
        case event do
          {:regular, text} ->
            case command?(text) do
              true -> process_command(step, text, state)
              false -> process_message(step, text, state)
            end

          {:callback, cb_id, cb_data} ->
            process_callback(step, cb_id, cb_data, state)
        end

      {false, state} ->
        case event do
          {:regular, _text} ->
            request_setting(:language, state)
            {step, state}

          {:callback, cb_id, cb_data} ->
            case cb_data do
              @callback_setting_set <> _ ->
                process_callback(step, cb_id, cb_data, state)

              _ ->
                request_setting(:language, state)
                {step, state}
            end
        end
    end
  end

  @spec language_set?(Session.State.t()) :: {boolean(), Session.State.t()}
  def language_set?(state) do
    case state.lang do
      nil ->
        case DB.get_language(state.chat_id) do
          :not_found ->
            {false, state}

          lang ->
            new_state = Session.State.with_lang(state, lang)
            {true, new_state}
        end

      _lang ->
        {true, state}
    end
  end

  def request_setting(:language, state) do
    buttons =
      Enum.map(Config.languages(), fn lang ->
        {
          to_string(lang),
          "#{@callback_setting_set}_#{@setting_language}_#{to_string(lang)}"
        }
      end)

    :ok =
      Message.Out.new("please choose language")
      |> Message.Out.with_buttons(buttons)
      |> Message.Out.send(state.chat_id)
  end

  defp process_callback(step, cb_id, @callback_setting_set <> _ = callback, state) do
    @callback_setting_set <> "_" <> @setting_language <> "_" <> lang = callback

    lang = String.to_atom(lang)

    DB.set_language(state.chat_id, lang)
    new_state = Session.State.with_lang(state, lang)

    :ok =
      Message.Out.new("language is set")
      |> Message.Out.callback(cb_id)

    {step, new_state}
  end

  # ---------------------------- COMMAND NEW --------------------------------- #

  defp process_command(:awaiting_command = step, @command_new, state) do
    next_step = :awaiting_reminder_title
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_command(:awaiting_reminder_title = step, @command_new, state) do
    next_step = :awaiting_reminder_title
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_command(:awaiting_reminder_timeout = step, @command_new, state) do
    next_step = :awaiting_reminder_timeout
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  # -------------------------------------------------------------------------- #

  # ---------------------------- COMMAND CANCEL ------------------------------ #

  defp process_command(:awaiting_command = step, @command_cancel, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_command(:awaiting_reminder_title = step, @command_cancel, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_command(:awaiting_reminder_timeout = step, @command_cancel, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  # -------------------------------------------------------------------------- #

  # ----------------------------- COMMAND LIST ------------------------------- #

  defp process_command(:awaiting_command = step, @command_list, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_command(:awaiting_reminder_title = step, @command_list, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_command(:awaiting_reminder_timeout = step, @command_list, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  # -------------------------------------------------------------------------- #

  # --------------------------- COMMAND SETTINGS ----------------------------- #

  defp process_command(:awaiting_command = step, @command_settings, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_command(:awaiting_reminder_title = step, @command_settings, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_command(:awaiting_reminder_timeout = step, @command_settings, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  # -------------------------------------------------------------------------- #

  defp process_message(:awaiting_command = step, _msg, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_message(:awaiting_reminder_title = step, _msg, state) do
    next_step = :awaiting_reminder_timeout
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp process_message(:awaiting_reminder_timeout = step, _msg, state) do
    next_step = :awaiting_command
    Logger.debug("CHAT: #{state.chat_id} | #{step} -> #{next_step}")

    :ok =
      Message.Out.new("#{step} -> #{next_step}")
      |> Message.Out.send(state.chat_id)

    {next_step, state}
  end

  defp command?(@command_new), do: true
  defp command?(@command_cancel), do: true
  defp command?(@command_list), do: true
  defp command?(@command_settings), do: true
  defp command?(_), do: false
end
