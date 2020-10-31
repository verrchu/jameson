defmodule Jameson.Inspector do
  alias Jameson.Session

  def sessions() do
    Supervisor.which_children(Session.Supervisor) |> Enum.map(
      fn({_, pid, _, _}) -> {pid, :sys.get_state(pid)} end
    )
  end
end
