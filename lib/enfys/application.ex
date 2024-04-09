defmodule Enfys.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Enfys.ActivitySupervisor},
      {DynamicSupervisor, strategy: :one_for_one, name: Enfys.LoadSupervisor},
    ]

    opts = [strategy: :one_for_one, name: Enfys.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
