defmodule Civo.LoadBalancers do
  @moduledoc """
  VPC load balancers (`/v2/loadbalancers`).

  Distribute TCP/UDP traffic across instance IPs. Create requires `name`,
  `network_id`, `region`, and `backends`.

  ## Create fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:name` | yes | Load balancer name |
  | `:network_id` | yes | Network ID |
  | `:region` | yes | Region code |
  | `:backends` | yes | List of backend maps (see below) |
  | `:algorithm` | no | `"round_robin"` (default) or `"least_connections"` |
  | `:external_traffic_policy` | no | `"Cluster"` or `"Local"` |
  | `:session_affinity` | no | `"None"` or `"ClientIP"` |
  | `:session_affinity_config_timeout` | no | Affinity timeout in seconds |
  | `:enable_proxy_protocol` | no | `"send"`, `"accept"`, or `"send_accept"` |
  | `:max_concurrent_requests` | no | Concurrency cap (default 10000) |

  ## Backend map

  Each backend is `%{ip: String.t(), protocol: "TCP" | "UDP", source_port: integer(), target_port: integer()}`.

  `/v2/vpc/loadbalancers` is an API alias of these endpoints.
  """

  @typedoc "A load balancer backend target."
  @type backend :: %{
          ip: String.t(),
          protocol: String.t(),
          source_port: integer(),
          target_port: integer()
        }

  @typedoc "Parameters for creating a VPC load balancer."
  @type t :: %__MODULE__{
          name: String.t() | nil,
          network_id: String.t() | nil,
          region: String.t() | nil,
          algorithm: String.t(),
          backends: [backend()] | nil,
          external_traffic_policy: String.t() | nil,
          session_affinity: String.t() | nil,
          session_affinity_config_timeout: integer() | nil,
          enable_proxy_protocol: String.t() | nil,
          max_concurrent_requests: integer() | nil
        }

  defstruct name: nil,
            network_id: nil,
            region: nil,
            algorithm: "round_robin",
            backends: nil,
            external_traffic_policy: nil,
            session_affinity: nil,
            session_affinity_config_timeout: nil,
            enable_proxy_protocol: nil,
            max_concurrent_requests: nil

  @path "loadbalancers"

  @doc """
  Lists load balancers (`GET /v2/loadbalancers`).
  """
  @spec list(String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def list(region \\ nil),
    do: Civo.get(@path, Civo.region_params(region))

  @doc """
  Fetches a load balancer by `id` (`GET /v2/loadbalancers/:id`).
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Creates a VPC load balancer (`POST /v2/loadbalancers`).
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params) do
    params
    |> Civo.require!([:name, :network_id, :region, :backends])
    |> then(&Civo.post(@path, &1))
  end

  @doc """
  Updates a load balancer (`PUT /v2/loadbalancers/:id`).

  Accepts a `t` struct or a map of fields to change.
  """
  @spec update(String.t(), map() | t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def update(id, params, region \\ nil)

  def update(id, %__MODULE__{} = params, region),
    do: update(id, Map.from_struct(params), region)

  def update(id, params, region) when is_map(params) do
    region = Civo.require_region!(region)

    @path
    |> Path.join(id)
    |> Civo.put(Civo.region_params(region, params))
  end

  @doc """
  Deletes a load balancer (`DELETE /v2/loadbalancers/:id`).
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end
end
