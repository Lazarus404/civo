defmodule Civo.Instances do
  @moduledoc """
  Compute instances (`/v2/instances`) and size listing (`/v2/sizes`).

  Create requires `hostname`, `size`, `network_id`, and `template_id`
  (a disk image ID from `Civo.DiskImages`). Most mutating calls need a
  `region` (argument or `config :civo, region: ...`).

  ## Create fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:hostname` | yes | FQDN hostname for the instance |
  | `:size` | yes | Size name from `available_sizes/1` (default `"g3.small"`) |
  | `:network_id` | yes | Network ID from `Civo.Networks` |
  | `:template_id` | yes | Disk image ID from `Civo.DiskImages` |
  | `:count` | no | How many instances to create (default `1`) |
  | `:region` | no | Region code; random if omitted and not configured |
  | `:public_ip` | no | `"none"` or `"create"` (default `"create"`) |
  | `:firewall_id` | no | Firewall in the same network |
  | `:reverse_dns` | no | Reverse DNS for the public IP |
  | `:initial_user` | no | First user (defaults from the disk image) |
  | `:ssh_key_id` | no | Uploaded SSH key ID; otherwise a password is returned |
  | `:script` | no | Init script written and run at first boot |
  | `:tags` | no | Space-separated tags |
  | `:private_ipv4` | no | Static private IP (VLAN / CivoStack Enterprise) |
  | `:allowed_ips` | no | Extra allowed IPs (CivoStack Enterprise) |
  | `:network_bandwidth_limit` | no | Mbit/s cap (CivoStack Enterprise) |
  """

  @typedoc "Parameters for creating an instance."
  @type t :: %__MODULE__{
          count: integer(),
          hostname: String.t() | nil,
          reverse_dns: String.t() | nil,
          size: String.t(),
          region: String.t() | nil,
          public_ip: String.t(),
          network_id: String.t() | nil,
          template_id: String.t() | nil,
          firewall_id: String.t() | nil,
          initial_user: String.t() | nil,
          ssh_key_id: String.t() | nil,
          script: String.t() | nil,
          tags: String.t() | nil,
          private_ipv4: String.t() | nil,
          allowed_ips: list() | nil,
          network_bandwidth_limit: integer() | nil
        }

  defstruct count: 1,
            hostname: nil,
            reverse_dns: nil,
            size: "g3.small",
            region: nil,
            public_ip: "create",
            network_id: nil,
            template_id: nil,
            firewall_id: nil,
            initial_user: nil,
            ssh_key_id: nil,
            script: nil,
            tags: nil,
            private_ipv4: nil,
            allowed_ips: nil,
            network_bandwidth_limit: nil

  @path "instances"

  @doc """
  Lists available instance sizes (`GET /v2/sizes`).

  Optional `params` may include filters accepted by the sizes endpoint.
  """
  @spec available_sizes(map()) :: Civo.Response.t() | Civo.Error.t()
  def available_sizes(params \\ %{}),
    do: Civo.get("sizes", params)

  @doc """
  Creates one or more instances (`POST /v2/instances`).

  See the module documentation for required and optional fields on `t`.
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params) do
    params
    |> Civo.require!([:hostname, :size, :network_id, :template_id])
    |> then(&Civo.post(@path, &1))
  end

  @doc """
  Lists instances (`GET /v2/instances`).

  Optional keys in `params`: `:tags`, `:page`, `:per_page`, `:region`.
  The response is typically paginated (`page`, `per_page`, `pages`, `items`).
  """
  @spec list(map()) :: Civo.Response.t() | Civo.Error.t()
  def list(params \\ %{}) when is_map(params),
    do: Civo.get(@path, params)

  @doc """
  Fetches a single instance by `id` (`GET /v2/instances/:id`).

  `region` is required by the API when not set in config.
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Deletes an instance (`DELETE /v2/instances/:id`).

  Snapshots and detached volumes are retained.
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end

  @doc """
  Replaces instance tags (`PUT /v2/instances/:id/tags`).

  Pass a space-separated `tags` string. An empty string clears all tags.
  """
  @spec retag(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def retag(id, tags, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "tags"])
    |> Civo.put(Civo.region_params(region, %{tags: tags}))
  end

  @doc """
  Hard-reboots an instance (`POST /v2/instances/:id/hard_reboots`).
  """
  @spec hard_reboots(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def hard_reboots(id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "hard_reboots"])
    |> Civo.post(Civo.region_params(region))
  end

  @doc """
  Soft-reboots an instance (`POST /v2/instances/:id/soft_reboots`).
  """
  @spec soft_reboots(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def soft_reboots(id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "soft_reboots"])
    |> Civo.post(Civo.region_params(region))
  end

  @doc """
  Shuts down an instance (`PUT /v2/instances/:id/stop`).
  """
  @spec stop(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def stop(id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "stop"])
    |> Civo.put(Civo.region_params(region))
  end

  @doc """
  Starts a stopped instance (`PUT /v2/instances/:id/start`).
  """
  @spec start(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def start(id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "start"])
    |> Civo.put(Civo.region_params(region))
  end

  @doc """
  Resizes an instance upward (`PUT /v2/instances/:id/resize`).

  `size` must be a valid size name from `available_sizes/1`.
  """
  @spec resize(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def resize(id, size, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "resize"])
    |> Civo.put(Civo.region_params(region, %{size: size}))
  end

  @doc """
  Assigns a firewall to an instance (`PUT /v2/instances/:id/firewall`).

  The firewall must belong to the instance's network.
  """
  @spec firewall(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def firewall(id, firewall_id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "firewall"])
    |> Civo.put(Civo.region_params(region, %{firewall_id: firewall_id}))
  end

  @doc """
  Sets permitted IPs for MAC/IP spoofing protection (`PUT .../allowed_ips`).

  CivoStack Enterprise private regions only. `ips` is a list of IP strings.
  """
  @spec allowed_ips(String.t(), list(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def allowed_ips(id, ips, region \\ nil) when is_list(ips) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "allowed_ips"])
    |> Civo.put(Civo.region_params(region, %{allowed_ips: ips}))
  end

  @doc """
  Sets per-instance network bandwidth limit in Mbit/s
  (`PUT .../network_bandwidth_limit`).

  CivoStack Enterprise private regions only.
  """
  @spec network_bandwidth_limit(String.t(), integer(), String.t() | nil) ::
          Civo.Response.t() | Civo.Error.t()
  def network_bandwidth_limit(id, limit, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "network_bandwidth_limit"])
    |> Civo.put(Civo.region_params(region, %{network_bandwidth_limit: limit}))
  end
end
