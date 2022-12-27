# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/lib/service/geospatial/photon.ex

defmodule Geospatial.Providers.Photon do
  @moduledoc """
  [Photon](https://photon.komoot.io) backend.
  """

  alias Geospatial.Address
  alias Geospatial.Providers.Provider
  alias Geospatial.HTTP
  import Geospatial.Providers.Provider, only: [endpoint: 1]
  require Logger

  @behaviour Provider

  @impl Provider
  @doc """
  Photon implementation for `c:Geospatial.Providers.Provider.geocode/3`.

  Note: It seems results are quite wrong.
  """
  @spec geocode(number(), number(), keyword()) :: list(Address.t())
  def geocode(lon, lat, options \\ []) do
    :geocode
    |> build_url(%{lon: lon, lat: lat}, options)
    |> fetch_features
  end

  @impl Provider
  @doc """
  Photon implementation for `c:Geospatial.Providers.Provider.search/2`.
  """
  @spec search(String.t(), keyword()) :: list(Address.t())
  def search(q, options \\ []) do
    :search
    |> build_url(%{q: q}, options)
    |> fetch_features
  end
  
  @impl Provider
  @doc """
  VOID implementation for `c:Geospatial.Providers.Provider.get_by_id/2`.
  """
  @spec get_by_id(String.t(), keyword()) :: list(Address.t())
  def get_by_id(_id, _options), do: []


  @spec build_url(atom(), map(), list()) :: String.t()
  defp build_url(method, args, options) do
    limit = Keyword.get(options, :limit, 10)
    lang = Keyword.get(options, :lang, "en")
    coords = Keyword.get(options, :coords, nil)
    endpoint = Keyword.get(options, :endpoint, endpoint(__MODULE__))

    case method do
      :search ->
        url = "#{endpoint}/api/?q=#{URI.encode(args.q)}&lang=#{lang}&limit=#{limit}"
        if is_nil(coords), do: url, else: url <> "&lat=#{coords.lat}&lon=#{coords.lon}"

      :geocode ->
        "#{endpoint}/reverse?lon=#{args.lon}&lat=#{args.lat}&lang=#{lang}&limit=#{limit}"
    end
  end

  @spec fetch_features(String.t()) :: list(Address.t())
  defp fetch_features(url) do
    Logger.debug("Asking photon with #{url}")

    with {:ok, %{status: 200, body: body}} <- HTTP.get(url),
         %{"features" => features} <- body do
      process_data(features)
    else
      _ ->
        Logger.error("Asking photon with #{url}")
        []
    end
  end

  defp process_data(features) do
    features
    |> Enum.map(fn %{"geometry" => geometry, "properties" => properties} ->
      coordinates = geometry |> Map.get("coordinates") |> Provider.coordinates()

      %Address{
        country: Map.get(properties, "country"),
        locality: Map.get(properties, "city"),
        region: Map.get(properties, "state"),
        description: Map.get(properties, "name") || street_address(properties),
        geom: coordinates,
        timezone: Provider.timezone(coordinates),
        postal_code: Map.get(properties, "postcode"),
        street: properties |> street_address(),
        origin_provider: "photon"
      }
    end)
  end

  defp street_address(properties) do
    if Map.has_key?(properties, "housenumber") do
      Map.get(properties, "housenumber") <> " " <> Map.get(properties, "street")
    else
      Map.get(properties, "street")
    end
  end
end
