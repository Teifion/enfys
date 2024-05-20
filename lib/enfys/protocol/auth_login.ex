defmodule Enfys.Protocol.AuthLogin do
  @moduledoc false
  alias Enfys.Support.Socket

  @spec perform(any(), String.t()) :: any()
  def perform(socket, name) do
    Socket.speak(socket, %{
      "name" => "enfys/login",
      "command" => %{
        "name" => name
      }
    })
  end
end
