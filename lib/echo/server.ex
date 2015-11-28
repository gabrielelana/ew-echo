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
    {:noreply, {:echo, socket_client}}
  end

  def handle_info({:tcp, socket_client, command}, {mode, socket_client}) do
    Logger.info("<<[#{inspect self}] #{String.strip(command)}")
    {mode, response} = handle_command(mode, command)
    :gen_tcp.send(socket_client, "#{response}\n")
    {:noreply, {mode, socket_client}}
  end

  def handle_info({:tcp_closed, socket_client}, socket_client) do
    {:stop, :normal, socket_client}
  end


  def handle_command(:echo, <<"REDIX", _::binary>>) do
    {:redix, "OK"}
  end
  def handle_command(:echo, command) do
    {:echo, command |> String.strip}
  end
  def handle_command(:redix, <<"SET", parameters::binary>>) do
    [key, value] = parameters |> String.strip |> String.split
    Redix.set(key, value)
    {:redix, "OK"}
  end
  def handle_command(:redix, <<"GET", parameters::binary>>) do
    key = parameters |> String.strip
    {:redix, Redix.get(key, "UNKNOWN")}
  end
  def handle_command(:redix, <<"ECHO", _::binary>>) do
    {:echo, "OK"}
  end
  def handle_command(:redix, command) do
    {:redix, "UNKNOWN COMMAND \"#{command}\""}
  end
end
