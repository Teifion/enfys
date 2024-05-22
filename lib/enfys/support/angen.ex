defmodule Enfys.Support.Angen do
  @moduledoc """

  """
  require Logger

  @spec check_is_up() :: any()
  def check_is_up() do
    case check_site_is_up() do
      {:ok, data} ->
        data

      {:error, reason} ->
        Logger.error(reason)
        IO.puts "Use -s to skip the check"
        :timer.sleep(100)
        System.halt()
    end
  end

  # We make a request to the enfys start url to ensure everything is running
  # and ready to go
  @spec check_site_is_up() :: {:ok, map} | {:error, String.t()}
  defp check_site_is_up() do
    host = Application.get_env(:enfys, :site_host)
    port = Application.get_env(:enfys, :site_port)

    with {:ok, conn} <- Mint.HTTP.connect(:http, host, port),
      {:ok, conn, _request_ref} <- Mint.HTTP.request(conn, "POST", "/api/enfys/start", [], nil)
      do
        receive do
          message ->
            case Mint.HTTP.stream(conn, message) do
              {:ok, _conn, responses} ->
                {:ok, data} = extract_data(responses)
                {:ok, data}
            end
        end
      else
        {:error, %Mint.TransportError{reason: :econnrefused}} ->
          {:error, "Cannot reach server"}
    end
  end

  @spec extract_data(list) :: {:ok, map} | {:error, any()}
  defp extract_data(responses) do
    {:data, _ref, raw_data} = responses
    |> Enum.filter(fn
      {type, _, _} -> type == :data
      _ -> false
    end)
    |> hd

    Jason.decode(raw_data)
  end
end
