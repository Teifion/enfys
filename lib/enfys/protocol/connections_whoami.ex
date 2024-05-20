defmodule Enfys.Protocol.ConnectionsWhoami do
  @moduledoc false
  alias Enfys.Support.Socket

  @spec perform(any()) :: any()
  def perform(socket) do
    Socket.speak(socket, %{
      "name" => "connections/whoami",
      "command" => %{}
    })
  end
end
