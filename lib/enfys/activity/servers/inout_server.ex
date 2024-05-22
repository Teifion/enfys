defmodule Enfys.Activity.InOutServer do
  @moduledoc """

  """
  alias Enfys.{Activity, Protocol}
  alias Enfys.Support.Socket
  use GenServer
  require Logger

  @interval_ms 1000
  @disconnect_chance 0.7
  @connect_chance 0.7

  defmodule State do
    @moduledoc false
    defstruct [:user_id, :socket, :name, :mode]
  end

  # GenServer behaviour
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  @impl GenServer
  @spec init(any()) :: {:ok, State.t()}
  def init(opts) do
    name_format = Map.get(opts, :name_format, "InOutServer:{{index}}")

    name = name_format
      |> String.replace("{{index}}", to_string(opts.index))

    state = %State{
      socket: Socket.new(),
      name: name <> Application.get_env(:enfys, :salt, ""),
      mode: :ready,
      user_id: nil
    }

    :timer.send_interval(@interval_ms, :tick)

    Activity.cast_manager({:register_agent, opts.type, name})

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:tick, %{mode: :waiting} = state) do
    state = listen_and_handle(state)
    {:noreply, state}
  end

  def handle_info(:tick, %{user_id: nil, mode: :ready} = state) do
    if :rand.uniform() > @connect_chance do
      Protocol.AuthLogin.perform(state.socket, state.name)
      {:noreply, struct(state, %{mode: :waiting})}
    else
      {:noreply, state}
    end
  end

  def handle_info(:tick, %{mode: :ready} = state) do
    if :rand.uniform() > @disconnect_chance do
      Protocol.AuthDisconnect.perform(state.socket)
      {:noreply, struct(state, %{mode: :ready, user_id: nil, socket: Socket.new()})}
    else
      {:noreply, state}
    end
  end

  @spec handle_msg(String.t(), map(), State.t()) :: State.t()
  defp handle_msg("auth/logged_in", message, state) do
    changes = %{
      user_id: message["user"]["id"],
      mode: :ready
    }

    struct(state, changes)
  end

  defp listen_and_handle(state) do
    Socket.listen_all(state.socket)
    |> Enum.reduce(state, fn (msg, acc) ->
      handle_msg(msg["name"], msg["message"], acc)
    end)
  end
end
