defmodule Jameson.Types do
  @type lang() :: :en
  @type session_step() ::
          :awaiting_command
          | :awaiting_reminder_title
          | :awaiting_reminder_timeout
end
