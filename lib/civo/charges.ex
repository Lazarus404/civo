defmodule Civo.Charges do
  @moduledoc """
  Hourly usage charges (`GET /v2/charges`).

  Optional `from` / `to` timestamps in RFC 3339. The API accepts at most
  a 31-day range.
  """

  @doc """
  Lists usage charges (`GET /v2/charges`).

  Pass `from` and/or `to` as RFC 3339 strings (e.g.
  `"2024-01-01T00:00:00Z"`). Omitting both uses the API default window.
  """
  @spec list(String.t() | nil, String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def list(from \\ nil, to \\ nil),
    do: Civo.get("charges", %{from: from, to: to})
end
