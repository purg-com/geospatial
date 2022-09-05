defmodule Geospatial.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [TzWorld.Backend.DetsWithIndexCache]

    opts = [strategy: :one_for_one, name: Geospatial.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
