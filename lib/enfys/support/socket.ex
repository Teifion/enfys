defmodule Enfys.Support.Socket do
  @moduledoc """

  """

  def new() do
    host = Application.get_env(:enfys, :socket_host)
    port = Application.get_env(:enfys, :socket_port)

    {:ok, socket} = :ssl.connect(host, port,
      active: false,
      verify: :verify_none
    )
    socket
  end

  @spec speak(any(), map) :: any()
  @spec speak(any(), map, non_neg_integer()) :: any()
  def speak(socket, data, sleep \\ 100) do
    msg = Jason.encode!(data)
    :ok = :ssl.send(socket, msg <> "\n")
    :timer.sleep(sleep)
    socket
  end

  @doc """
  Grabs a message from the socket, if there are multiple messages it will only
  grab the first one
  """
  @spec listen(any()) :: map() | :timeout | :closed
  @spec listen(any(), non_neg_integer()) :: map() | :timeout | :closed
  def listen(socket, timeout \\ 100) do
    case :ssl.recv(socket, 0, timeout) do
      # This sometimes borks because there are two messages in the queue and it gets both
      # will need to refactor this to return a list and update all tests accordingly
      {:ok, reply} ->
        reply |> to_string |> Jason.decode!()

      # reply
      # |> to_string
      # |> String.split("\n")
      # |> Enum.map(fn
      #   "" ->
      #     nil
      #   s ->
      #     Jason.decode!(s)
      # end)
      # |> Enum.reject(&(&1 == nil))

      {:error, :timeout} ->
        :timeout

      {:error, :closed} ->
        :closed
    end
  end

  @doc """
  Groups the list of responses according to their name
  """
  @spec group_responses([map()]) :: map()
  def group_responses(responses) do
    responses
    |> Enum.group_by(fn r ->
      r["name"]
    end)
  end

  @doc """
  Grabs all messages in the socket
  """
  @spec listen_all(any()) :: any()
  @spec listen_all(any(), non_neg_integer()) :: any()
  def listen_all(socket, timeout \\ 100) do
    case :ssl.recv(socket, 0, timeout) do
      {:ok, reply} ->
        # In theory there should only ever be one message in the socket but we do this because
        # sometimes there are two and then it errors. If you're using listen_all you
        # are already expecting a list so ez pz
        messages =
          reply
          |> to_string
          |> String.split("\n")
          |> Enum.map(fn
            "" ->
              nil

            s ->
              Jason.decode!(s)
          end)
          |> Enum.reject(&(&1 == nil))

        messages ++ listen_all(socket, timeout)

      {:error, :timeout} ->
        []

      {:error, :closed} ->
        []
    end
  end

  @doc """
  Reads all messages in the socket and discards them.
  """
  @spec flush_socket(any()) :: :ok
  def flush_socket(socket) do
    case :ssl.recv(socket, 0, 5) do
      {:ok, _reply} ->
        flush_socket(socket)

      {:error, :timeout} ->
        :ok

      {:error, :closed} ->
        :ok
    end
  end
end
