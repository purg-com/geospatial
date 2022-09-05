# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/lib/service/geospatial/addok.ex

defmodule Geospatial.Providers.Addok do
  @moduledoc """
  [Addok](https://github.com/addok/addok) backend.
  """

  alias Geospatial.Address
  alias Geospatial.Providers.Provider
  alias Geospatial.HTTP
  import Geospatial.Providers.Provider, only: [endpoint: 1]
  require Logger

  @behaviour Provider

  @impl Provider
  @doc """
  Addok implementation for `c:Geospatial.Providers.Provider.geocode/3`.
  """
  @spec geocode(String.t(), keyword()) :: list(Address.t())
  def geocode(lon, lat, options \\ []) do
    :geocode
    |> build_url(%{lon: lon, lat: lat}, options)
    |> fetch_features
  end

  @impl Provider
  @doc """
  Addok implementation for `c:Geospatial.Providers.Provider.search/2`.
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
    endpoint = Keyword.get(options, :endpoint, endpoint(__MODULE__))

    case method do
      :geocode ->
        "#{endpoint}/reverse/?lon=#{args.lon}&lat=#{args.lat}&limit=#{limit}"

      :search ->
        "#{endpoint}/search/?q=#{URI.encode(args.q)}&limit=#{limit}"
        |> add_parameter(options, :country_code)
        |> add_parameter(options, :type)
    end
  end

  @spec fetch_features(String.t()) :: list(Address.t())
  defp fetch_features(url) do
    Logger.debug("Asking addok with #{url}")

    with {:ok, %{status: 200, body: body}} <- HTTP.get(url),
         %{"features" => features} <- body do
      process_data(features)
    else
      _ ->
        Logger.error("Asking addok with #{url}")
        []
    end
  end

  defp process_data(features) do
    features
    |> Enum.map(fn %{"geometry" => geometry, "properties" => properties} ->
      coordinates = geometry |> Map.get("coordinates") |> Provider.coordinates()

      %Address{
        country: Map.get(properties, "country", default_country()),
        locality: Map.get(properties, "city"),
        region: Map.get(properties, "context"),
        description: Map.get(properties, "name") || street_address(properties),
        geom: coordinates,
        timezone: Provider.timezone(coordinates),
        postal_code: Map.get(properties, "postcode"),
        street: properties |> street_address(),
        origin_provider: "addok"
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

  @spec add_parameter(String.t(), Keyword.t(), atom()) :: String.t()
  defp add_parameter(url, options, key) do
    value = Keyword.get(options, key)

    if is_nil(value), do: url, else: do_add_parameter(url, key, value)
  end

  @spec do_add_parameter(String.t(), :type, :administrative | atom()) :: String.t()
  defp do_add_parameter(url, :type, :administrative),
    do: "#{url}&type=municipality"

  defp do_add_parameter(url, :type, _type), do: url

  defp default_country do
    Application.get_env(:geospatial, __MODULE__) |> get_in([:default_country]) ||
      "France"
  end
end
