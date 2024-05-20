defmodule Enfys.Protocol.LobbyOpen do
  @moduledoc false
  alias Enfys.Support.Socket

  @spec perform(any(), String.t()) :: any()
  def perform(socket, name) do
    Socket.speak(socket, %{
      "name" => "lobby/open",
      "command" => %{
        "name" => name
      }
    })
  end
end
