defmodule Civo.Kubernetes do
  @moduledoc """
  Kubernetes clusters are a number of instances on the Civo 
  cloud platform running the Kubernetes cloud orchestration platform.
  """

  #  a name for your cluster, must be unique within your account (required)
  defstruct name: nil,
            #  the number of instances to create (optional, the default at the time of writing is 3)
            num_target_nodes: nil,
            # the size of each node (optional, the default is currently g2.small)
            target_nodes_size: "g2.small",
            #  the version of k3s to install (optional, the default is currently the latest available)
            kubernetes_version: nil,
            #  a space separated list of tags, to be used freely as required (optional)
            tags: ""

  @type t :: %{
          name: String.t(),
          num_target_nodes: integer(),
          target_nodes_size: String.t(),
          kubernetes_version: String.t(),
          tags: String.t()
        }

  @path "kubernetes/clusters"
  @apps "kubernetes/applications"

  @doc """
  Creates a new K3s cluster.

  Any user can create a cluster, providing it's within their quota. 
  The size of the instances is from a list of sizes.

  ### Request
  The following parameter(s) should be sent along with the request:

  | Name  | Description |
  | ----- | ----------- |
  | `name` | a name for your cluster, must be unique within your account (required) |
  | `num_target_nodes` | the number of instances to create (optional, the default at the time of writing is 3) |
  | `target_nodes_size` | the size of each node (optional, the default is currently g2.small) |
  | `kubernetes_version` | the version of k3s to install (optional, the default is currently the latest available) |
  | `tags` | a space separated list of tags, to be used freely as required (optional) |

  ### Response
  The response is a JSON object that describes the initial setup of the cluster, future calls to get clusters may return more information (as underlying nodes are created, applications are installed, etc).

  ```elixir
  {
    "id": "69a23478-a89e-41d2-97b1-6f4c341cee70",
    "name": "your-cluster-name",
    "version": "2",
    "status": "ACTIVE",
    "ready": true,
    "num_target_nodes": 1,
    "target_nodes_size": "g2.xsmall",
    "built_at": "2019-09-23T13:04:23.000+01:00",
    "kubeconfig": "YAML_VERSION_OF_KUBECONFIG_HERE\n",
    "kubernetes_version": "0.8.1",
    "api_endpoint": "https://your.cluster.ip.address:6443",
    "dns_entry": "69a23478-a89e-41d2-97b1-6f4c341cee70.k8s.civo.com",
    "tags": [],
    "created_at": "2019-09-23T13:02:59.000+01:00",
    "instances": [{
      "hostname": "kube-master-HEXDIGITS",
      "size": "g2.xsmall",
      "region": "lon1",
      "created_at": "2019-09-23T13:03:00.000+01:00",
      "status": "ACTIVE",
      "firewall_id": "5f0ba9ed-5ca7-4e14-9a09-449a84196d64",
      "public_ip": "your.cluster.ip.address",
      "tags": ["civo-kubernetes:installed", "civo-kubernetes:master"]
    }],
    "installed_applications": [{
      "application": "Traefik",
      "title": null,
      "version": "(default)",
      "dependencies": null,
      "maintainer": "@Rancher_Labs",
      "description": "A reverse proxy/load-balancer that's easy, dynamic, automatic, fast, full-featured, open source, production proven and provides metrics.",
      "post_install": "Some documentation here\n",
      "installed": true,
      "url": "https://traefik.io",
      "category": "architecture",
      "updated_at": "2019-09-23T13:02:59.000+01:00",
      "image_url": "https://api.civo.com/k3s-marketplace/traefik.png",
      "plan": null,
      "configuration": {}
    }]
  }
  ```
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params),
    do: Civo.post(@path, params)

  @doc """
  Retrieves a list of K3s clusters in the account.

  ### Request
  This request requires no parameters.

  ### Response
  The response is a JSON array of cluster objects, like the JSON 
  described for the `create` call above.
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Retrieves information for a specific cluster.

  ### Request
  This request requires only the ID parameter of the cluster to query.

  ### Response
  The response is a JSON object that describes the details for the 
  cluster as described under the `create` call above.
  """
  @spec get(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def get(id),
    do:
      @path
      |> Path.join(id)
      |> Civo.get()

  @doc """
  Updates a specific cluster.

  A user can update a cluster to rename it, scale the number of 
  nodes in the cluster or install an application from the Marketplace.

  ### Request
  This operation requires one of the following parameters.

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the cluster to update. |
  | `name` | the cluster's new name |
  | `num_target_nodes` | how many nodes should the cluster scale to. |
  | `applications` | a comma separated list of applications to install. Spaces within application names are fine, but shouldn't be either side of the comma. |

  ### Response
  The response is a JSON object that contains the updated cluster 
  information (the same as for `create`).
  """
  @spec update(String.t(), String.t(), integer(), String.t()) ::
          Civo.Response.t() | Civo.Error.t()
  def update(id, name, num_target_nodes, applications \\ ""),
    do:
      @path
      |> Path.join(id)
      |> Civo.put(%{name: name, num_target_nodes: num_target_nodes, applications: applications})

  @doc """
  Lists available applications to install into a cluster.

  A user can install applications in to their cluster from the 
  marketplace using the `update` call above.

  ### Request
  This operation doesn't require any additional parameters.

  ### Response
  The response is a JSON object that returns the applications in the marketplace.

  ```elixir
  [{
    "name": "MariaDB",
    "title": null,
    "version": "10.4.7",
    "default": null,
    "dependencies": ["Longhorn"],
    "maintainer": "hello@civo.com",
    "description": "MariaDB is a community-developed fork of MySQL intended to remain free under the GNU GPL.",
    "post_install": "Instructions go here\n",
    "url": "https://mariadb.com",
    "category": "database",
    "image_url": "https://api.civo.com/k3s-marketplace/mariadb.png",
    "plans": [{
      "label": "5GB",
      "configuration": {
        "VOLUME_SIZE": {
          "value": "5Gi"
        }
      }
    }, {
      "label": "10GB",
      "configuration": {
        "VOLUME_SIZE": {
          "value": "10Gi"
        }
      }
    }]
  }]
  ```
  """
  @spec applications() :: Civo.Response.t() | Civo.Error.t()
  def applications(),
    do:
      @apps
      |> Civo.get()

  @doc """
  A user can delete a cluster and all underlying nodes.

  ### Request
  This operation requires the ID of the cluster to delete.

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec delete(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete(id),
    do:
      @path
      |> Path.join(id)
      |> Civo.delete()

  @doc """
  Rebuilds a node in a cluster.

  A user can delete and recreate one of the underlying nodes, 
  if it's having a problem.

  ### Request
  This operation requires the cluster ID and a hostname parameter 
  containing the name of the node to recycle.

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec recycle(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def recycle(id, hostname),
    do:
      Path.join([@path, id, "recycle"])
      |> Civo.post(%{hostname: hostname})
end
