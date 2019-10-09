defmodule Civo.Volumes do
  @moduledoc """
  We provide a flexible size additional storage service for our 
  Instances called volumes. This creates and attaches an additional 
  virtual disk to the instance, allowing you to put backups or 
  database files on the separate volume and later move the volume 
  to another instance.

  As volume storage is chargeable, at any time these can be deleted.
  """
  #  A name that you wish to use to refer to this volume (required)
  defstruct name: nil,
            # A minimum of 1 and a maximum of your available disk space from your quota specifies the size of the volume in gigabytes (required).
            size_gb: nil,
            #  Mark the volume as bootable with a boolean (optional; defaults to false).
            bootable: nil

  @type t :: %{
          name: String.t(),
          size_gb: integer(),
          bootable: boolean()
        }

  @path "volumes"

  @doc """
  Create a volume for an account.

  Any user can create volumes to be attached to their instances, 
  this takes up usage from Disk space under their quota.

  Request
  The only required parameters are the name of the volume and the 
  size required in gigabytes.

  | Name | Description |
  | ---- | ----------- |
  | `name` | A name that you wish to use to refer to this volume (required) |
  | `size_gb` | A minimum of 1 and a maximum of your available disk space from your quota specifies the size of the volume in gigabytes (required). |
  | `bootable` | Mark the volume as bootable with a boolean (optional; defaults to false). |

  ### Response
  The response is a JSON object that confirms the details given, 
  with a potential null for openstack_id (as it may not have been 
  created in OpenStack yet).

  ```elixir
  {
    "result": "success",
    "id": "44aab548-61ca-11e5-860e-5cf9389be614",
    "name": "my-volume",
  }
  ```
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params),
    do: Civo.post(@path, params)

  @doc """
  List all volumes for an account.

  ### Request
  This request takes no parameters.

  ### Response
  The response is a JSON array of objects that describes 
  summary details for each instance.

  ```elixir
  [
    {
      "id": "44aab548-61ca-11e5-860e-5cf9389be614",
      "name": "my-volume",
      "instance_id": "null",
      "mountpoint": "null",
      "openstack_id": "null",
      "size_gb": 25,
      "bootable": false,
      "created_at": "2015-09-20T19:31:36+00:00"
    },
    // ...
  ]
  ```
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Resize a volume.

  An unattached volume can be increased in size by the user. 
  The upper limit is still the available space in the user's 
  quota, and a volume can never be reduced in size. Civo 
  knows nothing about what disk format you are using (Ext3, 
  Ext4, BTRFS, etc) so it's up to the user to expand their 
  filesystem afterwards.

  ### Request
  The only required parameters are the id of the volume and 
  the new size required in gigabytes.

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the volume (required). |
  | `size_gb` | A minimum of the existing size of the volume plus 1 and a maximum of your available disk space from your quota specifies the size of the volume in gigabytes (required). |

  ### Response
  The response is a simple JSON object that confirms the success of the call.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec resize(String.t(), integer()) :: Civo.Response.t() | Civo.Error.t()
  def resize(id, size_gb),
    do:
      Path.join([@path, id, "resize"])
      |> Civo.put(%{size_gb: size_gb})

  @doc """
  attach a volume to an instance.

  Once the volume is created and has an openstack_id, you 
  can attach it to the instance (which is like plugging a 
  USB drive into a computer - it still needs partitioning, 
  formatting and mounting).

  ### Request
  The required parameters are the id of the volume 
  and the ID of the instance.

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the volume (required). |
  | `instance_id` | the id of an instance that you wish to attach this volume to (required) |

  ### Response
  The response is a JSON object that confirms the details given, 
  with a potential null for openstack_id (as it may not have 
  been created in OpenStack yet).

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec attach(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def attach(id, instance_id),
    do:
      Path.join([@path, id, "attach"])
      |> Civo.put(%{instance_id: instance_id})

  @doc """
  Detach a volume from an instance.

  If you've finished with the volume or want to move it to 
  another instance, you can detach it from the instance (which 
  is like unplugging a USB drive from a computer - you should 
  still have safely unmounted the drive first or you risk 
  corruption).

  ### Request
  The only required parameter is the ID of the volume.

  ### Response
  The response is a JSON object that confirms the action is being 
  taken, with a potential null for openstack_id (as it may not 
  have been created in OpenStack yet).

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec detach(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def detach(id),
    do:
      Path.join([@path, id, "detach"])
      |> Civo.put()

  @doc """
  Delete a volume from an account.

  An account holder can remove a volume, freeing up the 
  space used (and therefore the cost).

  ### Request
  This request takes the ID of the volume 
  to delete. No confirmation step is required, 
  this step will remove the volume immediately.

  ### Response
  The response from the server will be a JSON block. The 
  response will include a result field and the HTTP status 
  will be 200 OK.

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
end
