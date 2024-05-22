defmodule Mix.Tasks.Enfys.Activity do
  @moduledoc """
  Run with mix enfys.activity
  """

  use Mix.Task
  alias Enfys.Support.Angen
  require Logger

  @impl Mix.Task
  @spec run(any()) :: nil
  def run(raw_args) do
    Mix.Task.run("app.start")

    if Enum.member?(raw_args, "-s") do
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
