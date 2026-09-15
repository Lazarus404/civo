defmodule Civo.Quota do
  @moduledoc """
  Account quota limits and current usage (`GET /v2/quota`).

  Returns counts such as instances, CPUs, RAM, volumes, and networks —
  both limit and in-use values for the authenticated account.
  """

  @doc """
  Fetches the current account quota (`GET /v2/quota`).
  """
  @spec get() :: Civo.Response.t() | Civo.Error.t()
  def get(),
    do: Civo.get("quota")
end
