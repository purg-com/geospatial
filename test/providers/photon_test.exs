# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/test/service/geospatial/photon_test.ex

defmodule Geospatial.Providers.PhotonTest do
  use Geospatial.DataCase

  import Mox

  alias Geospatial.Address
  alias Geospatial.Providers.Photon
  alias Geospatial.HTTP.Mock

  describe "search address" do
    test "returns a valid address from search" do
      data =
        File.read!("test/fixtures/geospatial/photon/search.json")
        |> Jason.decode!()

      Mock
      |> expect(:call, fn
        %{
          method: :get,
          url: "https://photon.komoot.de/api/?q=10%20rue%20Jangot&lang=en&limit=10"
        },
        _opts ->
          {:ok, %Tesla.Env{status: 200, body: data}}
      end)

      assert %Address{
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
               origin_provider: "photon"
             } == Photon.search("10 rue Jangot") |> hd
    end

    # Photon returns something quite wrong, so no need to test this right now.
    #    test "returns a valid address from reverse geocode" do
    #        assert %Address{
    #                 locality: "Lyon",
    #                 description: "",
    #                 region: "Auvergne-Rhône-Alpes",
    #                 country: "France",
    #                 postal_code: "69007",
    #                 street: "10 Rue Jangot",
    #                 geom: %Geo.Point{
    #                   coordinates: {4.8425657, 45.7517141},
    #                   properties: %{},
    #                   srid: 4326
    #                 },
    #                origin_provider: "photon"
    #               } ==
    #                 Photon.geocode(4.8425657, 45.7517141)
    #                 |> hd
    #    end
  end
end
