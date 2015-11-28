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
    {:noreply, socket_client}
  end

  def handle_info({:tcp, socket_client, message}, socket_client) do
    Logger.info("<<[#{inspect self}] #{String.strip(message)}")
    :gen_tcp.send(socket_client, message)
    {:noreply, socket_client}
  end

  def handle_info({:tcp_closed, socket_client}, socket_client) do
    {:stop, :normal, socket_client}
  end
end
