import Config

config :tesla, Geospatial.HTTP, adapter: Geospatial.HTTP.Mock

config :geospatial, Geospatial.Providers.Addok, endpoint: "https://api-adresse.data.gouv.fr"

config :geospatial, Geospatial.Providers.GoogleMaps,
  api_key: nil,
  fetch_place_details: true

config :geospatial, Geospatial.Providers.MapQuest, api_key: nil

config :geospatial, Geospatial.Providers.Nominatim,
  endpoint: "https://nominatim.openstreetmap.org",
  api_key: nil

config :geospatial, Geospatial.Providers.Photon, endpoint: "https://photon.komoot.io"

config :geospatial, Geospatial.HTTP, user_agent: fn -> "" end

config :geospatial, Geospatial.Service, service: Geospatial.Providers.Mock
