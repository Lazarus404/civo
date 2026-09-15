defmodule Civo.Kubernetes do
  @moduledoc """
  Managed K3s clusters (`/v2/kubernetes/clusters`).

  Create requires `name`, `region`, and `network_id`. Prefer `pools` for
  node topology. Node sizes are typically `g4s.kube.*`.

  ## Create fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:name` | yes | Unique cluster name |
  | `:region` | yes | Region code |
  | `:network_id` | yes | Network to place the cluster in |
  | `:pools` | no | List of `%{id, size, count}` node pools |
  | `:kubernetes_version` | no | K3s version (default: latest) |
  | `:cni_plugin` | no | `"flannel"` (default) or `"cilium"` |
  | `:tags` | no | Space-separated tags |
  | `:instance_firewall` | no | Existing firewall ID for nodes |
  | `:firewall_rule` | no | Semi-colon separated rules if no firewall ID |
  | `:applications` | no | Comma-separated marketplace apps (e.g. `"cert-manager"`) |

  ## Pool desired state

  On update, `:pools` is the full desired state: change `count` to scale,
  add a new pool object to create one, omit a pool to delete it. An empty
  `pools` list deletes all pools.
  """

  @typedoc "A Kubernetes node pool definition."
  @type pool :: %{id: String.t(), size: String.t(), count: integer()}

  @typedoc "Parameters for creating a cluster."
  @type t :: %__MODULE__{
          name: String.t() | nil,
          region: String.t() | nil,
          network_id: String.t() | nil,
          pools: [pool()] | nil,
          kubernetes_version: String.t() | nil,
          cni_plugin: String.t() | nil,
          tags: String.t() | nil,
          instance_firewall: String.t() | nil,
          firewall_rule: String.t() | nil,
          applications: String.t() | nil
        }

  defstruct name: nil,
            region: nil,
            network_id: nil,
            pools: nil,
            kubernetes_version: nil,
            cni_plugin: nil,
            tags: nil,
            instance_firewall: nil,
            firewall_rule: nil,
            applications: nil

  @path "kubernetes/clusters"
  @apps "kubernetes/applications"
  @versions "kubernetes/versions"

  @doc """
  Creates a cluster (`POST /v2/kubernetes/clusters`).

  See the module documentation for fields on `t`.
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params) do
    params
    |> Civo.require!([:name, :region, :network_id])
    |> then(&Civo.post(@path, &1))
  end

  @doc """
  Lists clusters in a region (`GET /v2/kubernetes/clusters`).

  Response is typically paginated (`items`, `page`, …).
  """
  @spec list(String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def list(region \\ nil) do
    region = Civo.require_region!(region)
    Civo.get(@path, Civo.region_params(region))
  end

  @doc """
  Fetches a cluster by `id` (`GET /v2/kubernetes/clusters/:id`).
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Updates a cluster (`PUT /v2/kubernetes/clusters/:id`).

  `params` may include `:name`, `:pools`, `:kubernetes_version`,
  `:applications`, and `:region`. See module docs for pool semantics.
  """
  @spec update(String.t(), map(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def update(id, params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    @path
    |> Path.join(id)
    |> Civo.put(Civo.region_params(region, params))
  end

  @doc """
  Lists marketplace applications (`GET /v2/kubernetes/applications`).
  """
  @spec applications() :: Civo.Response.t() | Civo.Error.t()
  def applications(),
    do: Civo.get(@apps)

  @doc """
  Lists installable Kubernetes versions (`GET /v2/kubernetes/versions`).
  """
  @spec versions() :: Civo.Response.t() | Civo.Error.t()
  def versions(),
    do: Civo.get(@versions)

  @doc """
  Deletes a cluster and its nodes (`DELETE /v2/kubernetes/clusters/:id`).
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end

  @doc """
  Rebuilds a single node (`POST /v2/kubernetes/clusters/:id/recycle`).

  `hostname` is the node instance hostname to recycle.
  """
  @spec recycle(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def recycle(id, hostname, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "recycle"])
    |> Civo.post(Civo.region_params(region, %{hostname: hostname}))
  end
end
