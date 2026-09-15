defmodule Civo.Firewalls do
  @moduledoc """
  Firewalls and rules (`/v2/firewalls`).

  New firewalls deny by default; open ports with `create_rule/2`. Create
  requires `name`, `network_id`, and `region`. Assign a firewall to an
  instance with `Civo.Instances.firewall/3`.

  ## Rule fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:protocol` | yes | `"tcp"`, `"udp"`, or `"icmp"` (default `"tcp"`) |
  | `:start_port` | yes | Start port (or single port) |
  | `:end_port` | no | End of port range |
  | `:cidr` | no | Remote CIDR (default `0.0.0.0/0`) |
  | `:direction` | no | `"ingress"` (default) or `"egress"` |
  | `:label` | no | Display label |
  | `:action` | no | `"allow"` (default) or `"deny"` |
  | `:region` | yes* | Region for the rule |

  `/v2/vpc/firewalls` is an API alias of these endpoints.
  """

  @typedoc "Parameters for creating or describing a firewall rule."
  @type t :: %__MODULE__{
          protocol: String.t(),
          start_port: integer() | String.t() | nil,
          end_port: integer() | String.t() | nil,
          cidr: String.t() | nil,
          direction: String.t(),
          label: String.t() | nil,
          action: String.t(),
          region: String.t() | nil
        }

  defstruct protocol: "tcp",
            start_port: nil,
            end_port: nil,
            cidr: nil,
            direction: "ingress",
            label: nil,
            action: "allow",
            region: nil

  @path "firewalls"

  @doc """
  Creates a firewall (`POST /v2/firewalls`).

  `extra` may include options such as `:create_default_rules`.
  """
  @spec create(String.t(), String.t(), String.t() | nil, map()) ::
          Civo.Response.t() | Civo.Error.t()
  def create(name, network_id, region \\ nil, extra \\ %{}) do
    region = Civo.require_region!(region)

    params =
      extra
      |> Map.merge(%{name: name, network_id: network_id})
      |> then(&Civo.region_params(region, &1))

    Civo.post(@path, params)
  end

  @doc """
  Lists firewalls (`GET /v2/firewalls`).
  """
  @spec list(String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def list(region \\ nil),
    do: Civo.get(@path, Civo.region_params(region))

  @doc """
  Fetches a firewall by `id` (`GET /v2/firewalls/:id`).
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Updates a firewall (`PUT /v2/firewalls/:id`).

  `params` typically includes `:name`.
  """
  @spec update(String.t(), map(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def update(id, params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    @path
    |> Path.join(id)
    |> Civo.put(Civo.region_params(region, params))
  end

  @doc """
  Creates a firewall rule (`POST /v2/firewalls/:id/rules`).

  Pass a `t` struct or a map of rule fields (see module docs).
  """
  @spec create_rule(String.t(), t() | map()) :: Civo.Response.t() | Civo.Error.t()
  def create_rule(firewall_id, %__MODULE__{} = params),
    do: create_rule(firewall_id, Map.from_struct(params))

  def create_rule(firewall_id, params) when is_map(params) do
    Path.join([@path, firewall_id, "rules"])
    |> Civo.post(params)
  end

  @doc """
  Lists rules for a firewall (`GET /v2/firewalls/:id/rules`).
  """
  @spec rules(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def rules(firewall_id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, firewall_id, "rules"])
    |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Updates a firewall rule (`PUT /v2/firewalls/:id/rules/:rule_id`).
  """
  @spec update_rule(String.t(), String.t(), map(), String.t() | nil) ::
          Civo.Response.t() | Civo.Error.t()
  def update_rule(firewall_id, rule_id, params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    Path.join([@path, firewall_id, "rules", rule_id])
    |> Civo.put(Civo.region_params(region, params))
  end

  @doc """
  Deletes a firewall (`DELETE /v2/firewalls/:id`).
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end

  @doc """
  Deletes a firewall rule (`DELETE /v2/firewalls/:id/rules/:rule_id`).
  """
  @spec delete_rule(String.t(), String.t(), String.t() | nil) ::
          Civo.Response.t() | Civo.Error.t()
  def delete_rule(firewall_id, rule_id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, firewall_id, "rules", rule_id])
    |> Civo.delete(Civo.region_params(region))
  end
end
