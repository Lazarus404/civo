defmodule Civo.InstanceSnapshots do
  @moduledoc """
  Instance snapshots (`/v2/instances/:id/snapshots`).

  Replaces the legacy `/v2/snapshots/:name` API. Snapshots are scoped to
  an instance: every call needs the instance ID, and most need a `region`.

  ## Create params

  Typical keys for `create/3`: `:name`, `:description`, and `:region`
  (injected from config when omitted).
  """

  @doc """
  Creates a snapshot of an instance
  (`POST /v2/instances/:instance_id/snapshots`).
  """
  @spec create(String.t(), map(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def create(instance_id, params \\ %{}, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    Path.join(["instances", instance_id, "snapshots"])
    |> Civo.post(Civo.region_params(region, params))
  end

  @doc """
  Lists snapshots for an instance
  (`GET /v2/instances/:instance_id/snapshots`).
  """
  @spec list(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def list(instance_id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join(["instances", instance_id, "snapshots"])
    |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Fetches a snapshot by ID
  (`GET /v2/instances/:instance_id/snapshots/:snapshot_id`).
  """
  @spec get(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(instance_id, snapshot_id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join(["instances", instance_id, "snapshots", snapshot_id])
    |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Updates a snapshot (e.g. name or description)
  (`PUT /v2/instances/:instance_id/snapshots/:snapshot_id`).
  """
  @spec update(String.t(), String.t(), map(), String.t() | nil) ::
          Civo.Response.t() | Civo.Error.t()
  def update(instance_id, snapshot_id, params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    Path.join(["instances", instance_id, "snapshots", snapshot_id])
    |> Civo.put(Civo.region_params(region, params))
  end

  @doc """
  Restores an instance from a snapshot
  (`POST /v2/instances/:instance_id/snapshots/:snapshot_id/restore`).

  This overwrites the instance disk with the snapshot contents.
  """
  @spec restore(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def restore(instance_id, snapshot_id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join(["instances", instance_id, "snapshots", snapshot_id, "restore"])
    |> Civo.post(Civo.region_params(region))
  end

  @doc """
  Deletes a snapshot
  (`DELETE /v2/instances/:instance_id/snapshots/:snapshot_id`).
  """
  @spec delete(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(instance_id, snapshot_id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join(["instances", instance_id, "snapshots", snapshot_id])
    |> Civo.delete(Civo.region_params(region))
  end
end
