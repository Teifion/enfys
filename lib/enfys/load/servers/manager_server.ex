defmodule Enfys.Load.ManagerServer do
  @moduledoc """
  The cluster manager for handling adding nodes to a cluster.

  You can disable this process with the config:
  ```
  config :Enfys,
    Enfys_clustering: false
  ```
  """
  use GenServer
  require Logger

  @interval_ms 500

  # GenServer behaviour
  def start_link(params, _opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      params,
      name: __MODULE__
    )
  end

  @impl GenServer
  def init(_params) do
    send(self(), :startup)

    {:ok, :pending}
  end

  # @impl GenServer
  # def handle_call(other, from, state) do
  #   Logger.warning("unhandled call to ClusterMemberServer: #{inspect(other)}. From: #{inspect(from)}")
  #   {:reply, :not_implemented, state}
  # end

  # @impl GenServer
  # def handle_cast(other, state) do
  #   Logger.warning("unhandled cast to ClusterMemberServer: #{inspect(other)}.")
  #   {:noreply, state}
  # end

  @impl GenServer
  def handle_info(:startup, state) do
    if Application.get_env(:enfys, :mode) != :test do
      send(self(), :tick)
      :timer.send_interval(@interval_ms, :tick)
    end

    {:noreply, state}
  end

  def handle_info(:tick, state) do
    IO.puts "#{__MODULE__}:#{__ENV__.line}"
    IO.inspect "TICK"
    IO.puts ""
    {:noreply, state}
  end

  # def handle_info({:nodeup, node_name}, state) do
  #   Logger.info("nodeup message to ClusterMemberServer: #{inspect(node_name)}.")
  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_info({:nodedown, node_name}, state) do
  #   node_to_remove = Atom.to_string(node_name)
  #   ClusterMemberLib.delete_cluster_member(node_to_remove)
  #   Logger.warning("nodedown message to ClusterMemberServer: #{inspect(node_name)}.")
  #   {:noreply, state}
  # end

  # @impl GenServer
  # def handle_info(other, state) do
  #   Logger.warning("unhandled message to ClusterMemberServer: #{inspect(other)}.")
  #   {:noreply, state}
  # end
end
