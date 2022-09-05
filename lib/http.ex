# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/lib/service/http/geospatial_client.ex

defmodule Geospatial.HTTP do
  @moduledoc """
  Tesla HTTP Basic Client
  with JSON middleware
  """

  use Tesla

  @default_opts [
    recv_timeout: 20_000
  ]

  adapter(Tesla.Adapter.Hackney, @default_opts)

  plug(Tesla.Middleware.FollowRedirects)

  plug(Tesla.Middleware.Timeout, timeout: 10_000)

  plug(Tesla.Middleware.Headers, [
    {"User-Agent", get_in(Application.get_env(:geospatial, __MODULE__), [:user_agent]).()}
  ])

  plug(Tesla.Middleware.JSON)
end
