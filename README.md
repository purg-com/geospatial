# Geospatial

This library extracts the [Mobilizon.Service.Geospatial](https://docs.joinmobilizon.org/administration/configure/geocoders) module from [Mobilizon](https://framagit.org/framasoft/mobilizon). The only new *feature* is the `Geospatial.Providers.Provider.get_by_id/2` function.  
> This particular repository aims to satisfy implementation contracts for get_by_id/2 in all providers.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `geospatial` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:geospatial, "~> 0.2.1", git: "https://github.com/thecarnie/geospatial/", branch: "master"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/geospatial>.

