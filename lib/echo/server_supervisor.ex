defmodule Echo.Server.Supervisor do
  use Supervisor

  def start_link(args, opts) do
    Supervisor.start_link(__MODULE__, args, opts)
  end

  def init(_) do
    children = [
      worker(Echo.Server, []),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
