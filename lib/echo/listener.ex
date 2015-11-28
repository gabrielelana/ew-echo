defmodule Echo.Listener do
  use GenServer
  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    options = [:binary, packet: :line, active: true, reuseaddr: true]
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
    case :gen_tcp.accept(socket_server, 500) do
      {:ok, socket_client} ->
        Logger.info "Accepted connection"
        serve(socket_client)
        GenServer.cast(self, :accept)
        {:noreply, socket_server}
      {:error, :timeout} ->
        GenServer.cast(self, :accept)
        {:noreply, socket_server}
      {:error, reason} ->
        {:stop, reason, socket_server}
    end
  end

  def terminate(reason, socket_server) do
    Logger.info "Listener terminating because #{inspect reason}"
    :gen_tcp.close(socket_server)
    :ok
  end

  defp serve(socket_client) do
    {:ok, server} = Supervisor.start_child(Echo.Server.Supervisor, [])
    :gen_tcp.controlling_process(socket_client, server)
    Echo.Server.meet(server, socket_client)
  end
end
