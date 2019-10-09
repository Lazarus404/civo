defmodule Civo.Snapshots do
  @moduledoc """
  Civo provides a backup service for Instances called snapshots. This takes 
  an exact copy of the instance's virtual hard drive. At any point an 
  instance can be restored to the state it was in when the snapshot was made. 
  These snapshots can also be used to build a new instance to scale 
  identically configured infrastructure.

  As snapshot storage is chargeable, at any time these can be deleted. They 
  can also be scheduled rather than immediately created, and if desired 
  repeated at the same schedule each week (although the repeated snapshot 
  will overwrite itself each week not keep multiple weekly snapshots).
  """

  # The ID of the instance to snapshot
  defstruct instance_id: nil,
            #  If true the instance will be shut down during the snapshot to ensure all files are in a consistent state (e.g. database tables aren't in the middle of being optimised and hence risking corruption). The default is false so you experience no interruption of service, but a small risk of corruption.
            safe: nil,
            # If a valid cron string is passed, the snapshot will be saved as an automated snapshot, continuing to automatically update based on the schedule of the cron sequence provided. The default is nil meaning the snapshot will be saved as a one-off snapshot.
            cron_timing: nil

  @type t :: %{
          instance_id: String.t(),
          safe: boolean(),
          cron_timing: String.t()
        }

  @path "snapshots"

  @doc """
  Any user can create snapshots for their instances, this space 
  is charged separately from their quota.

  ### Request
  The only required parameters are the instance ID and the 
  snapshot name. Two optional parameters of safe and cron_timing 
  can also be passed. If the snapshot already exists it will be 
  overwritten.

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the instance to create a snapshot of. |
  | `instance_id` | The ID of the instance to snapshot |
  | `safe` | If true the instance will be shut down during the snapshot to ensure all files are in a consistent state (e.g. database tables aren't in the middle of being optimised and hence risking corruption). The default is false so you experience no interruption of service, but a small risk of corruption. |
  | `cron_timing` | If a valid cron string is passed, the snapshot will be saved as an automated snapshot, continuing to automatically update based on the schedule of the cron sequence provided. The default is nil meaning the snapshot will be saved as a one-off snapshot. |

  ### Response
  The response is a JSON object that confirms the details given, 
  with a null for snapshot_at (as it won't have been taken yet).

  ```elixir
  {
    "id": "0ca69adc-ff39-4fc1-8f08-d91434e86fac",
    "instance_id": "44aab548-61ca-11e5-860e-5cf9389be614",
    "hostname": "server1.prod.example.com",
    "template_id": "0b213794-d795-4483-8982-9f249c0262b9",
    "openstack_snapshot_id": null,
    "region": "lon1",
    "name": "my-instance-snapshot",
    "safe": 1,
    "size_gb": 0,
    "state": "new",
    "cron_timing": null,
    "requested_at": null,
    "completed_at": null
  }
  ```
  """
  @spec create(String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def create(name, %__MODULE__{} = params),
    do:
      @path
      |> Path.join(name)
      |> Civo.put(params)

  @doc """
  Lists all snapshots in an account.

  ### Request
  This request takes no parameters.

  ### Response
  The response is a JSON array of objects that describes summary 
  details for each instance.

  ```elixir
  [
    {
      "id": "0ca69adc-ff39-4fc1-8f08-d91434e86fac",
      "instance_id": "44aab548-61ca-11e5-860e-5cf9389be614",
      "hostname": "server1.prod.example.com",
      "template_id": "0b213794-d795-4483-8982-9f249c0262b9",
      "openstack_snapshot_id": null,
      "region": "lon1",
      "name": "my-instance-snapshot",
      "safe": 1,
      "size_gb": 0,
      "state": "in-progress",
      "cron_timing": null,
      "requested_at": null,
      "completed_at": null
    },
    // ...
  ]
  ```
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  An account holder can remove a snapshot, freeing up 
  the space used (and therefore the cost).

  ### Request
  This request takes the name of the snapshot 
  to delete. No confirmation step is required, this 
  step will remove the snapshot immediately.

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
  def delete(name),
    do:
      @path
      |> Path.join(name)
      |> Civo.delete()
end
