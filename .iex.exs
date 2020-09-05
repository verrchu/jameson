defmodule Helpers do
  def set_reminder(secs) do
    id = Ulid.generate()
    deadline = (DateTime.utc_now |> DateTime.to_unix) + secs
    user_id = 228
    headline = "TEST"

    reminder = Jameson.Reminder.builder()
    |> Jameson.Reminder.with_id(id)
    |> Jameson.Reminder.with_deadline(deadline)
    |> Jameson.Reminder.with_user_id(user_id)
    |> Jameson.Reminder.with_headline(headline)

    Jameson.Registry.record(reminder)
  end
end
