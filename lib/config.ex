defmodule Jameson.Config do
  alias Jameson.Types

  @spec languages() :: [Types.lang()]
  def languages(), do: [:en]
end
