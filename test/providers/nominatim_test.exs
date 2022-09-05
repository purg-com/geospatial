# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/test/service/geospatial/nominatim_test.ex

defmodule Geospatial.Providers.NominatimTest do
  use Geospatial.DataCase

  import Mox

  alias Geospatial.Address
  alias Geospatial.Providers.Nominatim
  alias Geospatial.HTTP.Mock

  describe "search address" do
    test "returns a valid address from search" do
      data =
        File.read!("test/fixtures/geospatial/nominatim/search.json")
        |> Jason.decode!()

      Mock
      |> expect(:call, fn
        %{
          method: :get,
          url:
            "https://nominatim.openstreetmap.org/search?format=geocodejson&q=10%20rue%20Jangot&limit=10&accept-language=en&addressdetails=1&namedetails=1"
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: data}}
      end)

      assert [
               %Address{
                 locality: "Lyon",
                 description: "10 Rue Jangot",
                 region: "Auvergne-Rhône-Alpes",
                 country: "France",
                 postal_code: "69007",
                 street: "10 Rue Jangot",
                 timezone: "Europe/Paris",
                 geom: %Geo.Point{
                   coordinates: {4.8425657, 45.7517141},
                   properties: %{},
                   srid: 4326
                 },
                 origin_id: "3078260611",
                 type: "house",
                 origin_provider: "nominatim"
               }
             ] == Nominatim.search("10 rue Jangot")
    end

    test "returns a valid address from reverse geocode" do
      data =
        File.read!("test/fixtures/geospatial/nominatim/geocode.json")
        |> Jason.decode!()

      Mock
      |> expect(:call, fn
        %{
          method: :get,
          url:
            "https://nominatim.openstreetmap.org/reverse?format=geocodejson&lat=45.751718&lon=4.842569&accept-language=en&addressdetails=1&namedetails=1"
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: data}}
      end)

      assert [
               %Address{
                 locality: "Lyon",
                 description: "10 Rue Jangot",
                 region: "Auvergne-Rhône-Alpes",
                 country: "France",
                 postal_code: "69007",
                 street: "10 Rue Jangot",
                 timezone: "Europe/Paris",
                 geom: %Geo.Point{
                   coordinates: {4.8425657, 45.7517141},
                   properties: %{},
                   srid: 4326
                 },
                 origin_id: "3078260611",
                 type: "house",
                 origin_provider: "nominatim"
               }
             ] ==
               Nominatim.geocode(4.842569, 45.751718)
    end
  end
end
