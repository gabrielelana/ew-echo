defmodule Echo.Server do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def meet(pid, socket_client) do
    GenServer.cast(pid, {:meet, socket_client})
  end

  def init(_) do
    {:ok, :waiting}
  end

  def handle_cast({:meet, socket_client}, :waiting) do
    GenServer.cast(self, :serve)
    {:noreply, socket_client}
  end

  def handle_cast(:serve, :waiting), do: {:noreply, :waiting}
  def handle_cast(:serve, socket_client) do
    socket_client
    |> read_line
    |> echo_line
    |> continue
  end

  def terminate(reason, socket_server) do
    Logger.info "Server terminating because #{inspect reason}"
    :gen_tcp.close(socket_server)
    :ok
  end

  defp read_line({:error, _} = error), do: error
  defp read_line(socket_client) do
    case :gen_tcp.recv(socket_client, 0) do
      {:ok, line} ->
        Logger.info "[#{inspect self}] << #{String.strip line}"
        {socket_client, line}
      {:error, reason} ->
        {:error, reason, socket_client}
    end
  end

  defp echo_line({:error, _, _} = error), do: error
  defp echo_line({socket_client, line}) do
    case :gen_tcp.send(socket_client, line) do
      :ok ->
        socket_client
      {:error, reason} ->
        {:error, reason, socket_client}
    end
  end

  defp continue({:error, reason, socket_client}),
    do: {:stop, reason, socket_client}
  defp continue(socket_client) do
    GenServer.cast(self, :serve)
    {:noreply, socket_client}
  end
end
