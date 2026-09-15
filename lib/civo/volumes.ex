defmodule Civo.Volumes do
  @moduledoc """
  Block storage volumes (`/v2/volumes`).

  Create and attach are separate steps. Create requires `name`, `size_gb`,
  and `network_id`. Attach, detach, and delete require a `region`.

  ## Create fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:name` | yes | Display name |
  | `:size_gb` | yes | Size in gigabytes |
  | `:network_id` | yes | Network for the volume |
  | `:region` | no | Region code |
  """

  @typedoc "Parameters for creating a volume."
  @type t :: %__MODULE__{
          name: String.t() | nil,
          size_gb: integer() | nil,
          network_id: String.t() | nil,
          region: String.t() | nil
        }

  defstruct name: nil,
            size_gb: nil,
            network_id: nil,
            region: nil

  @path "volumes"

  @doc """
  Creates a volume (`POST /v2/volumes`).

  Does not attach the volume; call `attach/3` afterwards.
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params) do
    params
    |> Civo.require!([:name, :size_gb, :network_id])
    |> then(&Civo.post(@path, &1))
  end

  @doc """
  Lists volumes (`GET /v2/volumes`).
  """
  @spec list(String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def list(region \\ nil),
    do: Civo.get(@path, Civo.region_params(region))

  @doc """
  Attaches a volume to an instance (`PUT /v2/volumes/:id/attach`).

  A volume can only be attached to one instance at a time.
  """
  @spec attach(String.t(), String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def attach(id, instance_id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "attach"])
    |> Civo.put(Civo.region_params(region, %{instance_id: instance_id}))
  end

  @doc """
  Detaches a volume (`PUT /v2/volumes/:id/detach`).

  Unmount the filesystem on the instance first to avoid corruption.
  """
  @spec detach(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def detach(id, region \\ nil) do
    region = Civo.require_region!(region)

    Path.join([@path, id, "detach"])
    |> Civo.put(Civo.region_params(region))
  end

  @doc """
  Deletes a volume (`DELETE /v2/volumes/:id`).
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end
end
