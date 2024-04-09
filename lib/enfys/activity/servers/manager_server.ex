defmodule Enfys.Activity.ManagerServer do
  @moduledoc """

  """
  use GenServer
  require Logger
  alias Enfys.Activity

  @interval_ms 500

  @counts [
    {:lobby_host, 2, {Activity.LobbyHostServer, %{}}},
    # lobby_joiner: 5,
    # lobby_chatter: 3
  ]

  defmodule State do
    @moduledoc false
    defstruct [:counts]
  end


  # GenServer behaviour
  def start_link(params, _opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      params,
      name: __MODULE__
    )
  end

  @impl GenServer
  @spec init(any()) :: {:ok, State.t()}
  def init(_params) do
    state = %State{
      counts: %{}
    }

    :timer.send_interval(@interval_ms, :tick)

    {:ok, state}
  end

  @impl GenServer
  def handle_cast({:register_agent, type}, state) do
    c = Map.get(state.counts, type, 0)
    new_counts = Map.put(state.counts, type, c + 1)

    {:noreply, struct(state, %{counts: new_counts})}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    @counts
    |> Enum.filter(fn {key, target, _} ->
      current = Map.get(state.counts, key, 0)
      current < target
    end)
    |> Enum.each(fn {key, _, {module, data}} ->
      current = Map.get(state.counts, key, 0)
      start_agent(key, module, Map.put(data, :index, current))
    end)

    {:noreply, state}
  end

  defp start_agent(key, module, data) do
    id = UUID.uuid4()

    DynamicSupervisor.start_child(Enfys.ActivitySupervisor, {
      module,
      name: "#{module}-#{id}",
      data: Map.merge(%{
        type: key,
        id: id
      }, data)
    })
  end
end
