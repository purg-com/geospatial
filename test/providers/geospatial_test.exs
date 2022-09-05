# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/test/service/geospatial/geospatial_test.ex

defmodule Geospatial.ServiceTest do
  use Geospatial.DataCase
  alias Geospatial.Service

  describe "get service" do
    assert Service.service() === Elixir.Geospatial.Providers.Mock
  end
end
