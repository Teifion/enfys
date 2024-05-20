defmodule Enfys.Protocol.AuthDisconnect do
  @moduledoc false
  alias Enfys.Support.Socket

  @spec perform(any()) :: any()
  def perform(socket) do
    Socket.speak(socket, %{
      "name" => "connections/disconnect",
      "command" => %{}
    })
  end
end
