defmodule Civo.Firewalls do
  @moduledoc """
  The simplest solution for most customers is to configure a firewall within 
  their Instances using either iptables which is powerful or Uncomplicated 
  Firewall/ufw which is much simpler but only works on Ubuntu.

  As another option, customers can configure custom firewall rules for 
  their instances using the Firewall API which adjusts the security group 
  for your network of instances. These are a freely configurable option, 
  however customers should be careful to not lock out their access to the 
  instances.

  This API is effectively split in to two parts: 1) Managing firewalls 
  themselves, and 2) Managing rules within those firewalls.
  """
  #  the protocol choice from tcp, udp or icmp (the default if unspecified is tcp)
  defstruct protocol: nil,
            #  the start of the port range to configure for this rule (or the single port if required)
            start_port: nil,
            #  the end of the port range (this is optional, by default it will only apply to the single port listed in start_port)
            end_port: nil,
            #  the IP address of the other end (i.e. not your instance) to affect, or a valid network CIDR (defaults to being globally applied, i.e. 0.0.0.0/0)
            cidr: nil,
            # will this rule affect inbound or outbound traffic (by default this is inbound)
            direction: nil,
            # a string that will be the displayed name/reference for this rule (optional)
            label: nil

  @type t :: %{
          protocol: String.t(),
          start_port: integer(),
          end_port: integer(),
          cidr: String.t(),
          direction: String.t(),
          label: String.t()
        }

  @path "firewalls"

  @doc """
  Create a firewall for an account.

  Any user can create firewalls for their network of instances, 
  there is a quota'd limit to the number of firewalls that can be 
  created, but generally this is much higher than most customers 
  will require and it can be increased if required.

  ### Request
  
  | Name | Description |
  | ---- | ----------- |
  | `name` | A unique name for this firewall within your account |

  ### Response
  The response is a JSON object that confirms the details given, 
  with a null for firewall rule_at (as it won't have been taken yet).

  ```elixir
  {
    "result": "success",
    "id": "84c38c6b-e7ae-43c9-b8d2-7294cb811e1a",
    "name": "instance-123456"
  }
  ```
  """
  @spec create(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def create(name),
    do: Civo.post(@path, %{name: name})

  @doc """
  Create rules for a firewall.

  An account holder can create firewall rules for a specific 
  firewall, but there is a quota'd limit to the number of rules 
  that can be created, but generally this is much higher than 
  most customers will require and it can be increased if required.

  ### Request
  The following parameters are required for setting firewall rules 
  (note: there's no allow/deny choice as the default for a new 
  firewall is to deny everything, so you only need to open the 
  ports/port ranges needed):

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the firewall to apply the rules to. |
  | `protocol` | the protocol choice from tcp, udp or icmp (the default if unspecified is tcp) |
  | `start_port` | the start of the port range to configure for this rule (or the single port if required) |
  | `end_port` | the end of the port range (this is optional, by default it will only apply to the single port listed in start_port) |
  | `cidr` | the IP address of the other end (i.e. not your instance) to affect, or a valid network CIDR (defaults to being globally applied, i.e. 0.0.0.0/0) |
  | `direction` | will this rule affect inbound or outbound traffic (by default this is inbound) |
  | `label` | a string that will be the displayed name/reference for this rule (optional) |

  ### Response
  The response is a JSON object that confirms the details given, 
  with a null for firewall rule_at (as it won't have been taken yet).

  ```elixir
  {
    "id": "1d0b4bec-2e94-44bd-9c08-8927aefa99cd",
    "firewall_id": "878d9dca-1687-4162-966e-281b2cc6bf2c",
    "openstack_security_group_rule_id": null,
    "protocol": "tcp",
    "start_port": "443",
    "end_port": "443",
    "cidr": [
      "0.0.0.0/0"
    ],
    "direction": "ingress",
    "label": null
  }
  ```
  """
  @spec rules(String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def rules(id, %__MODULE__{} = params),
    do:
      Path.join([@path, id, "rules"])
      |> Civo.post(params)

  @doc """
  Retrieve rules for a firewall.

  ### Request
  This request takes the id of a firewall.

  ### Response
  The response is a JSON array of objects that describes 
  summary details for each instance.

  ```elixir
  [
    {
      "id": "1d0b4bec-2e94-44bd-9c08-8927aefa99cd",
      "firewall_id": "84c38c6b-e7ae-43c9-b8d2-7294cb811e1a",
      "openstack_security_group_rule_id": null,
      "protocol": "tcp",
      "start_port": "443",
      "end_port": "443",
      "cidr": [
        "0.0.0.0/0"
      ],
      "direction": "ingress",
      "label": "My Rule",
    }
  ]
  ```
  """
  @spec rules(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def rules(id),
    do:
      Path.join([@path, id, "rules"])
      |> Civo.get()

  @doc """
  List firewalls for an account.

  ### Request
  This request takes no parameters.

  ### Response
  The response is a JSON array of objects that describes summary 
  details for each instance. It shows clearly how many rules it 
  contains and how many instances are currently configured to be 
  using it (you can share firewalls between multiple instances).

  ```elixir
  [
    {
      "id": "84c38c6b-e7ae-43c9-b8d2-7294cb811e1a",
      "name": "instance-123456",
      "openstack_security_group_id": null,
      "rules_count": 3,
      "instances_count": 10,
      "region": "lon1"
    }
  ]
  ```
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Delete a firewall from an account.

  An account holder can remove a firewall, freeing up the space 
  used within their quota. 

  Note: Firewalls can exist even if the instances have all be 
  removed, so if you are not setting up a firewall per instance, 
  you should monitor the list of firewalls for any that has a zero 
  instance_count and delete them, or their take up quota allocation.

  ### Request
  This request takes the ID of the firewall 
  to delete. No confirmation step is required, 
  this step will remove the firewall immediately.

  ### Response
  The response from the server will be a JSON block. The response 
  will include a result field and the HTTP status will be 202 
  Accepted.

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
  Delete a rule from a firewall.

  An account holder can remove a firewall rule, freeing up 
  the usage of their quota.

  ### Request
  This request takes the ID of the firewall rule to delete and 
  the name of the firewall. No confirmation step is required, 
  this step will remove the firewall rule immediately.

  ### Response
  The response from the server will be a JSON block. The response 
  will include a result field and the HTTP status will be 202 
  Accepted.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec delete(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete(firewall_id, rule_id),
    do:
      Path.join([@path, firewall_id, "rules", rule_id])
      |> Civo.delete()
end
