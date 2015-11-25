defmodule Echo.Server do
  use GenServer
  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    options = [:binary, packet: :line, active: false, reuseaddr: true]
    case :gen_tcp.listen(port, options) do
      {:ok, socket_server} ->
        Logger.info "Listening on #{port}"
        GenServer.cast(self, :accept)
        {:ok, socket_server}
      {:error, reason} ->
        {:stop, reason}
    end
  end

  def handle_cast(:accept, socket_server) do
    case :gen_tcp.accept(socket_server) do
      {:ok, socket_client} ->
        Logger.info "Accepted connection"
        serve(socket_client)
        GenServer.cast(self, :accept)
        {:noreply, socket_server}
      {:error, reason} ->
        {:stop, reason, socket_server}
    end
  end

  def terminate(reason, socket_server) do
    Logger.info "Terminating because #{reason}"
    :gen_tcp.close(socket_server)
    :ok
  end

  defp serve({:error, _}), do: :ok
  defp serve(socket_client) do
    socket_client
    |> read_line
    |> echo_line
    |> serve
  end

  defp read_line(socket_client) do
    case :gen_tcp.recv(socket_client, 0) do
      {:ok, line} ->
        {socket_client, line}
      {:error, _} = error ->
        error
    end
  end

  defp echo_line({:error, _} = error), do: error
  defp echo_line({socket_client, line}) do
    case :gen_tcp.send(socket_client, line) do
      :ok ->
        socket_client
      {:error, _} = error ->
        error
    end
  end
end
