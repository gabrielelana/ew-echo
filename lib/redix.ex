defmodule Redix do
  use GenServer

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def get(key, default \\ nil) do
    GenServer.call(Redix, {:get, key, default})
  end

  def set(key, value) do
    GenServer.cast(Redix, {:set, key, value})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:set, key, value}, store) do
    store = Map.put(store, key, value)
    {:noreply, store}
  end

  def handle_call({:get, key, default}, _, store) do
    value = Map.get(store, key, default)
    {:reply, value, store}
  end
end
