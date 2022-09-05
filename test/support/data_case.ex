defmodule Geospatial.DataCase do
  use ExUnit.CaseTemplate

  Mox.defmock(Geospatial.HTTP.Mock, for: Tesla.Adapter)
end
