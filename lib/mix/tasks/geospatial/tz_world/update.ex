# This file is derived from Mobilizon:
# SPDX-License-Identifier: AGPL-3.0-only
# Upstream: https://framagit.org/framasoft/mobilizon/-/blob/main/lib/mix/tasks/mobilizon/tz_world/update.ex.ex

defmodule Mix.Tasks.Geospatial.TzWorld.Update do
  use Mix.Task
  alias Mix.Tasks.TzWorld.Update, as: TzWorldUpdate
  require Logger

  @shortdoc "Wrapper on `tz_world.update` task."

  @moduledoc """
  Changes `Logger` level to `:info` before downloading.
  Changes level back when downloads ends.

  ## Update TzWorld data

      mix geospatial.tz_world.update
  """

  @impl true
  def run(_args) do
    level = Logger.level()
    Logger.configure(level: :info)

    TzWorldUpdate.run(nil)

    Logger.configure(level: level)
  end
end
