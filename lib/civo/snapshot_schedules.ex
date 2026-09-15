defmodule Civo.SnapshotSchedules do
  @moduledoc """
  Automated snapshot schedules (`/v2/resourcesnapshotschedules`).

  Schedules periodically snapshot instances (or other supported resources)
  according to a cron-like timing and retention policy.

  ## Create / update params

  Pass a map. Typical keys include:

  * `:name` — schedule name
  * `:cron_expression` — when to run
  * `:retention` — how many snapshots to keep
  * `:instance_id` / resource identifiers as required by the API
  * `:region` — region code (or rely on config)
  """

  @path "resourcesnapshotschedules"

  @doc """
  Creates a snapshot schedule (`POST /v2/resourcesnapshotschedules`).
  """
  @spec create(map(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def create(params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)
    Civo.post(@path, Civo.region_params(region, params))
  end

  @doc """
  Lists snapshot schedules (`GET /v2/resourcesnapshotschedules`).
  """
  @spec list(String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def list(region \\ nil) do
    region = Civo.require_region!(region)
    Civo.get(@path, Civo.region_params(region))
  end

  @doc """
  Fetches a snapshot schedule by `id`
  (`GET /v2/resourcesnapshotschedules/:id`).
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Updates a snapshot schedule (`PUT /v2/resourcesnapshotschedules/:id`).
  """
  @spec update(String.t(), map(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def update(id, params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    @path
    |> Path.join(id)
    |> Civo.put(Civo.region_params(region, params))
  end

  @doc """
  Deletes a snapshot schedule (`DELETE /v2/resourcesnapshotschedules/:id`).
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end
end
