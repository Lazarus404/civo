defmodule Civo.Networks do
  @moduledoc """
  Private networks (`/v2/networks`).

  Create with a `label` and optional CIDR / DNS settings. Rename and
  delete require a `region`. Networks cannot be deleted while instances
  still use them.

  `/v2/vpc/networks` is an API alias of these endpoints.
  """

  @path "networks"

  @doc """
  Creates a private network (`POST /v2/networks`).

  ## Options in `opts`

  * `:region` — region code
  * `:cidr_v4` — RFC 1918 CIDR for the network
  * `:nameservers_v4` — comma-separated DNS servers
  * `:ipv4_enabled` — whether IPv4 is enabled (default true)
  """
  @spec create(String.t(), map()) :: Civo.Response.t() | Civo.Error.t()
  def create(label, opts \\ %{}) when is_map(opts) do
    Civo.post(@path, Map.put(opts, :label, label))
  end

  @doc """
  Lists networks (`GET /v2/networks`).
  """
  @spec list(String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def list(region \\ nil),
    do: Civo.get(@path, Civo.region_params(region))

  @doc """
  Fetches a network by `id` (`GET /v2/networks/:id`).
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Renames a network (`PUT /v2/networks/:id`).

  Sets the display `label`.
  """
  @spec rename(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def rename(id, label, region \\ nil) do
    region = Civo.require_region!(region)

    @path
    |> Path.join(id)
    |> Civo.put(Civo.region_params(region, %{label: label}))
  end

  @doc """
  Deletes a network (`DELETE /v2/networks/:id`).

  Fails if any instances still use the network.
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end
end
