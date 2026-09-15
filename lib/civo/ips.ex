defmodule Civo.IPs do
  @moduledoc """
  Reserved public IPs (`/v2/ips`).

  Reserve an address, then `assign/3` it to an instance (or other
  supported resource). The same resources are also available under
  `/v2/vpc/ips` on the API; this client uses `/v2/ips`.

  ## Actions

  Use `actions/3` with `%{action: "assign", assign_to_id: ...}` or
  `%{action: "unassign"}`, or the helpers `assign/3` and `unassign/2`.
  """

  @path "ips"

  @doc """
  Lists reserved IPs (`GET /v2/ips`).

  Requires `:region` in `params` (or config). Optional: `:page`,
  `:per_page`.
  """
  @spec list(map()) :: Civo.Response.t() | Civo.Error.t()
  def list(params \\ %{}) when is_map(params) do
    params
    |> ensure_region_in_map()
    |> then(&Civo.get(@path, &1))
  end

  @doc """
  Creates a reserved IP (`POST /v2/ips`).

  `name` is a display label for the reservation.
  """
  @spec create(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def create(name, region \\ nil) do
    region = Civo.require_region!(region)
    Civo.post(@path, Civo.region_params(region, %{name: name}))
  end

  @doc """
  Fetches a reserved IP by `id` (`GET /v2/ips/:id`).
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Updates a reserved IP (`PUT /v2/ips/:id`).

  Typically used to rename (`%{name: ...}`).
  """
  @spec update(String.t(), map(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def update(id, params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    @path
    |> Path.join(id)
    |> Civo.put(Civo.region_params(region, params))
  end

  @doc """
  Deletes a reserved IP (`DELETE /v2/ips/:id`).
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end

  @doc """
  Performs an action on a reserved IP (`POST /v2/ips/:id/actions`).

  `params` must include `:action` (`"assign"` or `"unassign"`). For
  assign, also include `:assign_to_id`.
  """
  @spec actions(String.t(), map(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def actions(id, params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "actions"])
    |> Civo.post(Civo.region_params(region, params))
  end

  @doc """
  Assigns a reserved IP to a resource (`POST /v2/ips/:id/actions`).

  `assign_to_id` is typically an instance ID.
  """
  @spec assign(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def assign(id, assign_to_id, region \\ nil) do
    actions(id, %{action: "assign", assign_to_id: assign_to_id}, region)
  end

  @doc """
  Unassigns a reserved IP (`POST /v2/ips/:id/actions`).
  """
  @spec unassign(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def unassign(id, region \\ nil),
    do: actions(id, %{action: "unassign"}, region)

  defp ensure_region_in_map(params) do
    region = Map.get(params, :region) || Map.get(params, "region")
    Map.put(params, :region, Civo.require_region!(region))
  end
end
