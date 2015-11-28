defmodule Echo.Supervisor do
  use Supervisor

  def start_link(port) do
    Supervisor.start_link(__MODULE__, port)
  end

  def init(port) do
    children = [
      supervisor(Echo.Server.Supervisor, [[], [name: Echo.Server.Supervisor]]),
      worker(Redix, [[], [name: Redix]]),
      worker(Echo.Listener, [port]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
