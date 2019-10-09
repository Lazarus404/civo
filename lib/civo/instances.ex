defmodule Civo.Instances do
  @moduledoc """
  Instances are running virtual servers on the Civo cloud 
  platform. They can be of variable size.
  """

  # the number of instances to create (optional, default is 1)
  defstruct count: 1,
            # a fully qualified domain name that should be set as the instance's 
            # hostname (required)
            hostname: nil,
            # a fully qualified domain name that should be used as the instance's 
            # IP's reverse DNS (optional, uses the hostname if unspecified)
            reverse_dns: nil,
            # the name of the size, from the current list, 
            # e.g. "g2.small" (required)
            size: "g2.small",
            # the identifier for the region, from the current region 
            # (optional; a random one will be picked by the system)
            region: nil,
            # this should be either none, create or from. If from is specified 
            # then the move_ip_from parameter should also be specified (and 
            # contain the ID of the instance that will be releasing its IP). 
            # As aliases true will be treated the same as create and false will 
            # be treated the same as none. If create or true is specified it will 
            # automatically allocate an initial public IP address, rather than 
            # having to add the first one later (optional; default is create)
            public_ip: "none",
            # this must be the ID of the network from the network 
            # listing (optional; default network used when not specified)
            network_id: nil,
            # the ID for the template to use to build the instance, from the 
            # current templates. Parameter also accepted as template. 
            # (optional; but must be specified if no snapshot is specified)
            template_id: nil,
            # the ID for the snapshot to use to build the instance, from your 
            # snapshots (optional; but must be specified if no template is 
            # specified)
            snapshot_id: nil,
            # the name of the initial user created on the server (optional; 
            # this will default to the template's default_username and fallback 
            # to "civo")
            initial_user: nil,
            # the ID of an already uploaded SSH public key to use for login 
            # to the default user (optional; if one isn't provided a random 
            # password will be set and returned in the initial_password field)
            ssh_key_id: nil,
            # a space separated list of tags, to be used freely as required 
            # (optional)
            tags: nil

  @type t :: %{
          count: integer(),
          hostname: String.t(),
          reverse_dns: String.t(),
          size: String.t(),
          region: String.t(),
          public_ip: String.t(),
          network_id: String.t(),
          template_id: String.t(),
          snapshot_id: String.t(),
          initial_user: String.t(),
          ssh_key_id: String.t(),
          tags: String.t()
        }

  @path "instances"

  @doc """
  Lists available VM sizes supported by Civo.

  ### Request
  This request doesn't take any parameters.

  ### Response
  The response from the server will be a JSON array of sizes, 
  each with a name and the appropriate attributes.

  ```elixir
  [
    {
      "id": "d6b170f2-d2b3-4205-84c4-61898622393d",
      "name": "micro",
      "nice_name": "Micro",
      "cpu_cores": 1,
      "ram_mb": 1024,
      "disk_gb": 25,
      "description": "Micro - 1GB RAM, 1 CPU Core, 25GB SSD Disk",
      "selectable": true
    },
    // ...
  ]
  ```
  """
  def available_sizes(),
    do: Civo.get("sizes")

  @doc """
  Creates a new instance.

  Any user can create an instance, providing it's within their quota. 
  The size of the instance is from a list of sizes, as is the region 
  to host the instance. Instances in a single region for a given account 
  will all share an internal network, and can (optionally, but by default) 
  have one public IP address assigned to them.

  Instances are built from a template, which may be just a base operating 
  system such as ubuntu-14.04, or it may be a ready configured application 
  or control panel hosting system.

  ### Request
  The following parameter(s) should be sent along with the request:

  | Name | Description |
  | ---- | ----------- |
  | `count` | the number of instances to create (optional, default is 1) |
  | `hostname` | a fully qualified domain name that should be set as the instance's hostname (required) |
  | `reverse_dns` | a fully qualified domain name that should be used as the instance's IP's reverse DNS (optional, uses the hostname if unspecified) |
  | `size` | the name of the size, from the current list, e.g. "g2.small" (required) |
  | `region` | the identifier for the region, from the current region (optional; a random one will be picked by the system) |
  | `public_ip` | this should be either none, create or from. If from is specified then the move_ip_from parameter should also be specified (and contain the ID of the instance that will be releasing its IP). As aliases true will be treated the same as create and false will be treated the same as none. If create or true is specified it will automatically allocate an initial public IP address, rather than having to add the first one later (optional; default is create) |
  | `network_id` | this must be the ID of the network from the network listing (optional; default network used when not specified) |
  | `template_id` | the ID for the template to use to build the instance, from the current templates. Parameter also accepted as template. (optional; but must be specified if no snapshot is specified) |
  | `snapshot_id` | the ID for the snapshot to use to build the instance, from your snapshots (optional; but must be specified if no template is specified) |
  | `initial_user` | the name of the initial user created on the server (optional; this will default to the template's default_username and fallback to "civo") |
  | `ssh_key_id` | the ID of an already uploaded SSH public key to use for login to the default user (optional; if one isn't provided a random password will be set and returned in the initial_password field) |
  | `tags` | a space separated list of tags, to be used freely as required (optional) |

  ### Response
  The response is a JSON object that describes the initial setup of the 
  instance, these details may not be returned in future calls to list 
  instances.

  ```elixir
  {
    "id": "b177ae0e-60fa-11e5-be02-5cf9389be614",
    "openstack_server_id": "369588f7-de40-4eca-bc8d-4c2dbc1cc7f3",
    "hostname": "b177ae0e-60fa-11e5-be02-5cf9389be614.clients.civo.com",
    "reverse_dns": null,
    "size": "g2.xsmall",
    "region": "lon1",
    "network_id": "63906834-2455-4b72-b0c4-77617ef18b4e",
    "private_ip": "10.0.0.4",
    "public_ip": "31.28.66.181",
    "pseudo_ip": "172.31.0.230",
    "template_id": "f80a1698-8933-414f-92ac-a36d9cfc4ac9",
    "snapshot_id": null,
    "initial_user": "civo",
    "initial_password": "password_here",
    "ssh_key": "61f1b5c8-2c87-4cc7-b1af-6278f3050a28",
    "status": "ACTIVE",
    "notes": null,
    "firewall_id": "default",
    "tags": [
      "web",
      "main",
      "linux"
    ],
    "civostatsd_token": "f84d920f-c74b-4b48-a21e-5ff7a671e5f9",
    "civostatsd_stats": null,
    "civostatsd_stats_per_minute": [],
    "civostatsd_stats_per_hour": [],
    "openstack_image_id": null,
    "rescue_password": null,
    "volume_backed": true,
    "created_at": "2015-09-20T19:31:36+00:00"
  }
  ```
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params),
    do: Civo.post(@path, params)

  @doc """
  Lists all instances in the account.

  A list of instances accessible from an account is available by sending 
  a GET request to https://api.civo.com/v2/instances.

  ### Request
  This request requires no parameters. However you can optionally filter 
  the list of instances by passing in:

  | Name      | Description |
  | --------- | ----------- |
  | `tags`      | a space separated list of tags, to be used freely as required. If multiple are supplied, instances must much all tags to be returned (not one or more) |
  | `page`      | which page of results to return (defaults to 1) |
  | `per_page`  | how many instances to return per page (defaults to 20) |

  ### Response
  The response is a JSON array of objects that describes summary details 
  for each instance (the civostatsd_stats currently is just a string 
  containing CPU %, Memory %, Storage %).

  ```elixir
  [
    {
      "id": "b177ae0e-60fa-11e5-be02-5cf9389be614",
      "openstack_server_id": "369588f7-de40-4eca-bc8d-4c2dbc1cc7f3",
      "hostname": "b177ae0e-60fa-11e5-be02-5cf9389be614.clients.civo.com",
      "reverse_dns": null,
      "size": "g2.xsmall",
      "region": "lon1",
      "network_id": "63906834-2455-4b72-b0c4-77617ef18b4e",
      "private_ip": "10.0.0.4",
      "public_ip": "31.28.66.181",
      "pseudo_ip": "172.31.0.230",
      "template_id": "f80a1698-8933-414f-92ac-a36d9cfc4ac9",
      "snapshot_id": null,
      "initial_user": "civo",
      "initial_password": "password_here",
      "ssh_key": "61f1b5c8-2c87-4cc7-b1af-6278f3050a28",
      "status": "ACTIVE",
      "notes": null,
      "firewall_id": "default",
      "tags": [
        "web",
        "main",
        "linux"
      ],
      "civostatsd_token": "f84d920f-c74b-4b48-a21e-5ff7a671e5f9",
      "civostatsd_stats": null,
      "civostatsd_stats_per_minute": [],
      "civostatsd_stats_per_hour": [],
      "openstack_image_id": null,
      "rescue_password": null,
      "volume_backed": true,
      "created_at": "2015-09-20T19:31:36+00:00"
    },
    // ...
  ]
  ```
  """
  @spec list(String.t(), integer(), integer()) :: Civo.Response.t() | Civo.Error.t()
  def list(tags \\ "", page \\ 1, per_page \\ 20),
    do: Civo.get(@path, %{tags: tags, page: page, per_page: per_page})

  @doc """
  Gets information for a single instance.

  ### Request
  This request requires only the ID parameter.

  ### Response
  The response is a JSON object that describes the details for the instance 
  (the civostatsd_stats currently is just a string containing CPU %, Memory %, 
  Storage %).

  ```elixir
  {
    "id": "b177ae0e-60fa-11e5-be02-5cf9389be614",
    "openstack_server_id": "369588f7-de40-4eca-bc8d-4c2dbc1cc7f3",
    "hostname": "b177ae0e-60fa-11e5-be02-5cf9389be614.clients.civo.com",
    "reverse_dns": null,
    "size": "g2.xsmall",
    "region": "lon1",
    "network_id": "63906834-2455-4b72-b0c4-77617ef18b4e",
    "private_ip": "10.0.0.4",
    "public_ip": "31.28.66.181",
    "pseudo_ip": "172.31.0.230",
    "template_id": "f80a1698-8933-414f-92ac-a36d9cfc4ac9",
    "snapshot_id": null,
    "initial_user": "civo",
    "initial_password": "password_here",
    "ssh_key": "61f1b5c8-2c87-4cc7-b1af-6278f3050a28",
    "status": "ACTIVE",
    "notes": null,
    "firewall_id": "default",
    "tags": [
      "web",
      "main",
      "linux"
    ],
    "civostatsd_token": "f84d920f-c74b-4b48-a21e-5ff7a671e5f9",
    "civostatsd_stats": null,
    "civostatsd_stats_per_minute": [],
    "civostatsd_stats_per_hour": [],
    "openstack_image_id": null,
    "rescue_password": null,
    "volume_backed": true,
    "created_at": "2015-09-20T19:31:36+00:00"
  }
  ```
  """
  @spec get(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def get(id),
    do:
      @path
      |> Path.join(id)
      |> Civo.get()

  @doc """
  Deletes a single instance.

  ### Request
  This request takes the ID of the instance to delete. No confirmation step 
  is required, this step will remove the instance immediately but will 
  leave any snapshots taken of the instance and any mapped storage.

  ### Response
  The response from the server will be a JSON block. The response will 
  include a result field and the HTTP status will be 202 Accepted.

  ```elixir
  {
    "id": "b177ae0e-60fa-11e5-be02-5cf9389be614",
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
  Retags an instance.

  A user can retag an instance at any time, as they require.

  ### Request
  This operation requires the instance ID. If you 
  don't pass a tags parameter, it will remove all the existing tags.

  | Name    | Description |
  | ------- | ----------- |
  | `id`    | the id of the instance to retag. |
  | `tags`  | a space separated list of tags, to be used freely as required (optional) |

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec retag(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def retag(id, tags),
    do:
      Path.join([@path, id, "tags"])
      |> Civo.put(%{tags: tags})

  @doc """
  Hard reboots an instance.

  A user can reboot an instance at any time, for example 
  to fix a crashed piece of software.

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec hard_reboots(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def hard_reboots(id),
    do:
      Path.join([@path, id, "hard_reboots"])
      |> Civo.post()

  @doc """
  Soft reboots an instance.

  A user can reboot an instance at any time, for example 
  to fix a crashed piece of software.

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec soft_reboots(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def soft_reboots(id),
    do:
      Path.join([@path, id, "soft_reboots"])
      |> Civo.post()

  @doc """
  Shuts down an instance.

  A user can shut down an instance at any time, for example to stop 
  it from being attacked further.

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec stop(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def stop(id),
    do:
      Path.join([@path, id, "stop"])
      |> Civo.put()

  @doc """
  If shut-down, will restart an instance.

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec start(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def start(id),
    do:
      Path.join([@path, id, "start"])
      |> Civo.put()

  @doc """
  Resizes an instance.

  A user can resize an instance upwards, providing it's within 
  their quota. The size of the instance is from a list of sizes.

  ### Request

  | Name    | Description |
  | ------- | ----------- |
  | `id`    | the id of the instance to retag. |
  | `size`  | the new size identifier (see `available_sizes`) |

  ### Response
  The response is a JSON object that describes the initial setup 
  of the instance, these details may not be returned in future calls 
  to list instances.

  ```elixir
  {
    "id": "b177ae0e-60fa-11e5-be02-5cf9389be614",
    "hostname": "b177ae0e-60fa-11e5-be02-5cf9389be614.clients.civo.com",
    "size": "g1.small"
  }
  ```
  """
  @spec resize(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def resize(id, size),
    do:
      Path.join([@path, id, "resize"])
      |> Civo.put(%{size: size})

  @doc """
  Adds a firewall to an instance.

  ### Request
  The following parameter(s) should be sent along with the request:

  | Name         | Description |
  | ------------ | ----------- |
  | `id`         | the ID of the instance to attach the firewall |
  | `firewall_id` | the ID of the firewall to use, from the current list. If left blank or not sent, the default firewall will be used (open to all) |

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec firewall(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def firewall(id, firewall_id),
    do:
      Path.join([@path, id, "firewall"])
      |> Civo.put(%{firewall_id: firewall_id})

  @doc """
  Given two instances, one with a public IP and one without, you 
  can move the public IP.

  ### Request
  The required parameter are the target instance ID and 
  the public IP address. You must own both instances 
  and the target instance must not already have a public IP.

  ### Response
  The response is a JSON object that simply acknowledges the request.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec move_ip(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def move_ip(id, ip_address),
    do:
      Path.join([@path, id, "ip", ip_address])
      |> Civo.put()
end
