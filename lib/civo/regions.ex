defmodule Civo.Regions do
  @moduledoc """
  Available Civo regions (`GET /v2/regions`).

  Use region codes (e.g. `"LON1"`, `"NYC1"`) as the `region` argument on
  resource calls, or set `config :civo, region: "LON1"`.
  """

  @doc """
  Lists available regions (`GET /v2/regions`).
  """
  @spec available_regions() :: Civo.Response.t() | Civo.Error.t()
  def available_regions(),
    do: Civo.get("regions")
end
