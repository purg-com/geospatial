# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/lib/service/geospatial/pelias.ex

defmodule Geospatial.Providers.Pelias do
  @moduledoc """
  [Pelias](https://pelias.io) backend.

  Doesn't provide type of POI.
  """

  alias Geospatial.Address
  alias Geospatial.Providers.Provider
  alias Geospatial.HTTP
  import Geospatial.Providers.Provider, only: [endpoint: 1]
  require Logger

  @behaviour Provider

  @impl Provider
  @doc """
  Pelias implementation for `c:Geospatial.Providers.Provider.geocode/3`.
  """
  @spec geocode(number(), number(), keyword()) :: list(Address.t())
  def geocode(lon, lat, options \\ []) do
    :geocode
    |> build_url(%{lon: lon, lat: lat}, options)
    |> fetch_features
  end

  @impl Provider
  @doc """
  Pelias implementation for `c:Geospatial.Providers.Provider.search/2`.
  """
  @spec search(String.t(), keyword()) :: list(Address.t())
  def search(q, options \\ []) do
    :search
    |> build_url(%{q: q}, options)
    |> fetch_features
  end

  @spec build_url(atom(), map(), list()) :: String.t()
  defp build_url(method, args, options) do
    limit = Keyword.get(options, :limit, 10)
    lang = Keyword.get(options, :lang, "en")
    endpoint = Keyword.get(options, :endpoint, endpoint(__MODULE__))

    url =
      case method do
        :search ->
          "#{endpoint}/v1/autocomplete?text=#{URI.encode(args.q)}&lang=#{lang}&size=#{limit}"
          |> add_parameter(options, :coords)
          |> add_parameter(options, :type)

        :geocode ->
          "#{endpoint}/v1/reverse?point.lon=#{args.lon}&point.lat=#{args.lat}"
      end

    add_parameter(url, options, :country_code)
  end

  @spec fetch_features(String.t()) :: list(Address.t())
  defp fetch_features(url) do
    Logger.debug("Asking pelias with #{url}")

    with {:ok, %{status: 200, body: body}} <- HTTP.get(url),
         %{"features" => features} <- body do
      process_data(features)
    else
      _ ->
        Logger.error("Asking pelias with #{url}")
        []
    end
  end

  defp process_data(features) do
    features
    |> Enum.map(fn %{
                     "geometry" => %{"coordinates" => coordinates},
                     "properties" => properties
                   } ->
      address = process_address(properties)
      coordinates = Provider.coordinates(coordinates)
      %Address{address | geom: coordinates, timezone: Provider.timezone(coordinates)}
    end)
  end

  defp process_address(properties) do
    %Address{
      country: Map.get(properties, "country"),
      locality: Map.get(properties, "locality"),
      region: Map.get(properties, "region"),
      description: Map.get(properties, "name"),
      postal_code: Map.get(properties, "postalcode"),
      street: street_address(properties),
      origin_id: "#{Map.get(properties, "id")}",
      origin_provider: "pelias",
      type: get_type(properties)
    }
  end

  defp street_address(properties) do
    if Map.has_key?(properties, "housenumber") do
      "#{Map.get(properties, "housenumber")} #{Map.get(properties, "street")}"
    else
      Map.get(properties, "street")
    end
  end

  @administrative_layers [
    "neighbourhood",
    "borough",
    "localadmin",
    "locality",
    "county",
    "macrocounty",
    "region",
    "macroregion",
    "dependency"
  ]

  @spec get_type(map()) :: String.t() | nil
  defp get_type(%{"layer" => layer}) when layer in @administrative_layers, do: "administrative"
  defp get_type(%{"layer" => "address"}), do: "house"
  defp get_type(%{"layer" => "street"}), do: "street"
  defp get_type(%{"layer" => "venue"}), do: "venue"
  defp get_type(%{"layer" => _}), do: nil

  @spec add_parameter(String.t(), Keyword.t(), atom()) :: String.t()
  def add_parameter(url, options, key) do
    value = Keyword.get(options, key)

    if is_nil(value), do: url, else: do_add_parameter(url, key, value)
  end

  @spec do_add_parameter(String.t(), atom(), any()) :: String.t()
  defp do_add_parameter(url, :coords, value),
    do: "#{url}&focus.point.lat=#{value.lat}&focus.point.lon=#{value.lon}"

  defp do_add_parameter(url, :type, :administrative),
    do: "#{url}&layers=coarse"

  defp do_add_parameter(url, :type, _type), do: url

  defp do_add_parameter(url, :country_code, nil), do: url

  defp do_add_parameter(url, :country_code, country_code),
    do: "#{url}&boundary.country=#{country_code}"
end
