# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/lib/mobilizon/addresses/address.ex

defmodule Geospatial.Address do
  defstruct [
    :url,
    :description,
    :geom,
    :country,
    :locality,
    :region,
    :postal_code,
    :street,
    :origin_id,
    :origin_provider,
    :type,
    :timezone
  ]

  @type t :: %__MODULE__{
          country: String.t() | nil,
          locality: String.t() | nil,
          region: String.t() | nil,
          description: String.t() | nil,
          geom: Geo.Point.t() | nil,
          postal_code: String.t() | nil,
          street: String.t() | nil,
          type: String.t() | nil,
          url: String.t(),
          origin_id: String.t() | nil,
          origin_provider: String.t() | nil,
          timezone: String.t() | nil
        }
end
