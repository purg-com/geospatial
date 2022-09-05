# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/lib/service/geospatial/geospatial.ex

defmodule Geospatial.Service do
  @moduledoc """
  Module to load the service adapter defined inside the configuration.

  See `Geospatial.Providers.Provider`.
  """

  @doc """
  Returns the appropriate service adapter.

  According to the config behind
    `config :geospatial, Geospatial.Service,
       service: Geospatial.Providers.Module`
  """
  @spec service :: module
  def service, do: get_in(Application.get_env(:geospatial, __MODULE__), [:service])
end
