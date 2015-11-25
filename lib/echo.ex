defmodule Echo do
  use Application

  def start(type, []), do: start(type, Application.get_env(:echo, :port))
  def start(_type, port) do
    Echo.Server.start_link(port)
  end
end
