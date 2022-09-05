# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/test/support/mocks/geospatial_mock.ex

defmodule Geospatial.Providers.Mock do
  @moduledoc """
  Mock for Geospatial Provider implementations.
  """

  alias Geospatial.Address
  alias Geospatial.Providers.Provider

  @address %Address{description: "10 rue Jangot, Lyon", origin_id: "476"}
  @other_address %Address{description: "Anywhere", origin_id: "420"}

  @behaviour Provider

  @impl Provider
  def geocode(_lon, _lat, _options \\ [])
  def geocode(45.75, 4.85, _options), do: [@address]
  def geocode(_lon, _lat, _options), do: [@other_address]

  @impl Provider
  def search(_q, _options \\ []), do: [@address]

  @impl Provider
  def get_by_id("476", _options), do: [@address]
  def get_by_id(_id, _options), do: []
end
