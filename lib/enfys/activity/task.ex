defmodule Mix.Tasks.Enfys.Activity do
  @moduledoc """
  Run with mix enfys.activity

  You can override the options with:

  # Localhost example
  mix enfys.activity socket_host:127.0.0.1 socket_port:8201 site_host:localhost site_port:4000 user_password:password

  # Remote node example
  mix enfys.activity socket_host:node1.domain.co.uk socket_port:8201 site_host:node1.domain.co.uk site_port:443 user_password:password scale:1 salt:salt
  """

  use Mix.Task
  alias Enfys.Support.Angen
  require Logger

  @impl Mix.Task
  @spec run(any()) :: nil
  def run(raw_args) do
    Mix.Task.run("app.start")

    raw_args
    |> Enum.each(fn
      "site_host:" <> site_host ->
        Application.put_env(:enfys, :site_host, site_host)
      "site_port:" <> site_port_str ->
        site_port = String.to_integer(site_port_str)
        Application.put_env(:enfys, :site_port, site_port)

      "socket_host:" <> socket_host_str ->
        socket_host = String.to_charlist(socket_host_str)
        Application.put_env(:enfys, :socket_host, socket_host)
      "socket_port:" <> socket_port_str ->
        socket_port = String.to_integer(socket_port_str)
        Application.put_env(:enfys, :socket_port, socket_port)

      "user_password:" <> user_password ->
        Application.put_env(:enfys, :user_password, user_password)

      "scale:" <> scale_str ->
        scale = String.to_integer(scale_str)
        Application.put_env(:enfys, :scale, scale)

      "salt:" <> salt ->
        Application.put_env(:enfys, :salt, salt)
    end)

    if Enum.member?(raw_args, "skip-check") do
      IO.puts "Skipping check"
    else
      _data = Angen.check_is_up()
    end

    DynamicSupervisor.start_child(Enfys.ActivitySupervisor, {
      Enfys.Activity.ManagerServer,
      name: Enfys.Activity.ManagerServer
    })

    wait_forever()
    nil
  end

  defp wait_forever() do
    :timer.sleep(10_000)
    wait_forever()
  end
end
