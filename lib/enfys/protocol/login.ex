defmodule Enfys.Protocol.Login do
  alias Enfys.Support.Socket

  def perform(socket, name) do
    Socket.speak(socket, %{
      "name" => "enfys/login",
      "command" => %{
        "name" => name
      }
    })
  end
end
