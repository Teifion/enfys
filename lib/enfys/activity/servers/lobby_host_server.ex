defmodule Enfys.Activity.LobbyHostServer do
  @moduledoc """

  """
  alias Enfys.{Activity, Protocol}
  alias Enfys.Support.Socket
  use GenServer
  require Logger

  @interval_ms 500

  defmodule State do
    @moduledoc false
    defstruct [:server_id, :user_id, :mode, :socket, :name]
  end

  # GenServer behaviour
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  @impl GenServer
  @spec init(any()) :: {:ok, State.t()}
  def init(opts) do
    state = %State{
      socket: Socket.new(),
      server_id: opts.id,
      name: Map.get(opts, :name, "LobbyHostServer:#{opts.index}"),
      user_id: nil,
      mode: nil
    }

    :timer.send_interval(@interval_ms, :tick)

    Activity.cast_manager({:register_agent, opts.type})

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:tick, %{mode: :waiting} = state) do
    msgs = Socket.listen(state.socket)

    IO.puts "#{__MODULE__}:#{__ENV__.line}"
    IO.inspect msgs
    IO.puts ""

    {:noreply, state}
  end

  def handle_info(:tick, %{user_id: nil} = state) do
    Protocol.Login.perform(state.socket, state.name)

    {:noreply, struct(state, %{mode: :waiting})}
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end
end
