defmodule Enfys.Activity do
  alias Enfys.Activity.ManagerServer

  @spec cast_manager(any()) :: :ok
  def cast_manager(msg) do
    GenServer.cast(ManagerServer, msg)
  end

  @spec call_manager(any()) :: :ok
  def call_manager(msg) do
    GenServer.call(ManagerServer, msg)
  end
end
