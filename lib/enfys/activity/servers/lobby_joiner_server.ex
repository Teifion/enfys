defmodule Enfys.Activity.LobbyJoinerServer do
  @moduledoc """

  """
  alias Enfys.{Activity, Protocol}
  alias Enfys.Support.Socket
  use GenServer
  require Logger

  @interval_ms 500

  defmodule State do
    @moduledoc false
    defstruct [:server_id, :user_id, :lobby_id, :mode, :socket, :name, :flags]
  end

  # GenServer behaviour
  @spec start_link(list) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:data], [])
  end

  @impl GenServer
  @spec init(any()) :: {:ok, State.t()}
  def init(opts) do
    name_format = Map.get(opts, :name_format, "LobbyJoinerServer:{{index}}")

    name = name_format
      |> String.replace("{{index}}", to_string(opts.index))

    state = %State{
      socket: Socket.new(),
      server_id: opts.id,
      name: name,
      flags: Map.get(opts, :flags, []),
      user_id: nil,
      lobby_id: nil,
      mode: nil
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

  def handle_info(:tick, %{mode: :whoami} = state) do
    Protocol.ConnectionsWhoami.perform(state.socket)
    {:noreply, struct(state, %{mode: :waiting})}
  end

  def handle_info(:tick, %{user_id: nil} = state) do
    Protocol.AuthLogin.perform(state.socket, state.name)
    {:noreply, struct(state, %{mode: :waiting})}
  end

  def handle_info(:tick, %{lobby_id: nil} = state) do
    Protocol.LobbyOpen.perform(state.socket, state.name)
    {:noreply, struct(state, %{mode: :waiting})}
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end

  @spec handle_msg(String.t(), map(), State.t()) :: State.t()
  defp handle_msg("auth/logged_in", message, state) do
    changes = %{
      user_id: message["user"]["id"],
      mode: :logged_in
    }

    struct(state, changes)
  end

  defp handle_msg("lobby/opened", message, state) do
    changes = %{
      lobby_id: message["lobby_id"],
      mode: :hosting
    }

    struct(state, changes)
  end

  defp handle_msg("connections/youare", message, state) do
    mode = cond do
      message["client"]["lobby_id"] != nil -> :hosting
      true -> :logged_in
    end

    changes = %{
      lobby_id: message["client"]["lobby_id"],
      mode: mode
    }

    struct(state, changes)
  end

  defp handle_msg("connections/client_updated", message, state) do
    changes = case message["reason"] do
      "opened lobby" ->
        %{
          lobby_id: message["changes"]["lobby_id"],
          mode: :hosting
        }
    end

    struct(state, changes)
  end

  defp handle_msg("system/failure", message, state) do
    changes = case {message["command"], message["reason"]} do
      {"lobby/open", "Already in" <> _} ->
        # We tried to open a lobby but we're already in one, great
        %{
          mode: :whoami
        }

    end

    struct(state, changes)
  end

  defp listen_and_handle(state) do
    Socket.listen_all(state.socket)
    |> Enum.reduce(state, fn (msg, acc) ->
      handle_msg(msg["name"], msg["message"], acc)
    end)
  end
end
