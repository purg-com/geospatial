# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/lib/service/geospatial/provider.ex

defmodule Geospatial.Providers.Provider do
  @moduledoc """
  Provider Behaviour for Geospatial stuff.

  ## Supported backends

    * `Geospatial.Providers.Nominatim` [🔗](https://wiki.openstreetmap.org/wiki/Nominatim)
    * `Geospatial.Providers.Photon` [🔗](https://photon.komoot.io)
    * `Geospatial.Providers.Addok` [🔗](https://github.com/addok/addok)
    * `Geospatial.Providers.MapQuest` [🔗](https://developer.mapquest.com/documentation/open/)
    * `Geospatial.Providers.GoogleMaps` [🔗](https://developers.google.com/maps/documentation/geocoding/intro)
    * `Geospatial.Providers.Mimirsbrunn` [🔗](https://github.com/CanalTP/mimirsbrunn)
    * `Geospatial.Providers.Pelias` [🔗](https://pelias.io)


  ## Shared options

    * `:lang` Lang in which to prefer results. Used as a request parameter or
      through an `Accept-Language` HTTP header. Defaults to `"en"`.
    * `:country_code` An ISO 3166 country code. String or `nil`
    * `:limit` Maximum limit for the number of results returned by the backend.
      Defaults to `10`
    * `:api_key` Allows to override the API key (if the backend requires one) set
      inside the configuration.
    * `:endpoint` Allows to override the endpoint set inside the configuration.
  """

  alias Geospatial.Address

  @doc """
  Get an address from longitude and latitude coordinates.

  ## Options

  In addition to [the shared options](#module-shared-options), `c:geocode/3` also
  accepts the following options:

  * `zoom` Level of detail required for the address. Default: 15

  ## Examples

      iex> geocode(48.11, -1.77)
      %Address{}
  """
  @callback geocode(longitude :: number, latitude :: number, options :: keyword) ::
              [Address.t()]

  @doc """
  Search for an address

  ## Options

  In addition to [the shared options](#module-shared-options), `c:search/2` also
  accepts the following options:

  * `coords` Map of coordinates (ex: `%{lon: 48.11, lat: -1.77}`) allowing to
  give a geographic priority to the search. Defaults to `nil`.
  * `type` Filter by type of results. Allowed values:
     * `:administrative` (cities, regions)

  ## Examples

      iex> search("10 rue Jangot")
      %Address{}
  """
  @callback search(address :: String.t(), options :: keyword) :: [Address.t()]

  @doc """
  Lookup for an address by id
  """
  @callback get_by_id(id :: String.t(), options :: keyword) :: [Address.t()]

  @doc """
  Returns a `Geo.Point` for given coordinates
  """
  @spec coordinates([number | String.t()]) :: Geo.Point.t() | nil
  def coordinates([x, y]) when is_number(x) and is_number(y) do
    %Geo.Point{coordinates: {x, y}, srid: 4326}
  end

  def coordinates([x, y]) when is_binary(x) and is_binary(y) do
    %Geo.Point{coordinates: {String.to_float(x), String.to_float(y)}, srid: 4326}
  end

  def coordinates(_), do: nil

  @doc """
  Returns the timezone for a Geo.Point
  """
  @spec timezone(nil | Geo.Point.t()) :: nil | String.t()
  def timezone(nil), do: nil

  def timezone(%Geo.Point{} = point) do
    case TzWorld.timezone_at(point) do
      {:ok, tz} -> tz
      {:error, _err} -> nil
    end
  end

  @spec endpoint(atom()) :: String.t()
  def endpoint(provider) do
    Application.get_env(:geospatial, provider) |> get_in([:endpoint])
  end
end
