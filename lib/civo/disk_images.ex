defmodule Civo.DiskImages do
  @moduledoc """
  Disk images used to build instances (`/v2/disk_images`).

  Public image IDs are unique per region — always pass or configure a
  `region` when listing or fetching. Use the returned image ID as
  `template_id` on `Civo.Instances.create/1`.

  Custom images: call `create/1` to register metadata and receive a
  presigned upload URL, then `PUT` the qcow2/raw file yourself (this
  library does not stream the upload).

  ## Create fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:name` | yes | Image name |
  | `:distribution` | yes | Distro name (e.g. `"ubuntu"`) |
  | `:version` | yes | Distro version string |
  | `:os` | yes | `"linux"` or `"windows"` (default `"linux"`) |
  | `:region` | yes | Region for the image |
  | `:image_sha256` | yes | SHA-256 of the image file |
  | `:image_md5` | yes | MD5 of the image file |
  | `:image_size` | yes | Size of the image file in bytes |
  | `:logo_base64` | no | Optional logo as base64 |
  """

  @typedoc "Parameters for registering a custom disk image."
  @type t :: %__MODULE__{
          name: String.t() | nil,
          distribution: String.t() | nil,
          version: String.t() | nil,
          os: String.t(),
          region: String.t() | nil,
          image_sha256: String.t() | nil,
          image_md5: String.t() | nil,
          image_size: integer() | nil,
          logo_base64: String.t() | nil
        }

  defstruct name: nil,
            distribution: nil,
            version: nil,
            os: "linux",
            region: nil,
            image_sha256: nil,
            image_md5: nil,
            image_size: nil,
            logo_base64: nil

  @path "disk_images"

  @doc """
  Lists disk images (`GET /v2/disk_images`).

  Optional keys in `params`: `:region`, `:type` (e.g. `"custom"` for
  user images only).
  """
  @spec list(map()) :: Civo.Response.t() | Civo.Error.t()
  def list(params \\ %{}) when is_map(params),
    do: Civo.get(@path, params)

  @doc """
  Fetches a disk image by `id` (`GET /v2/disk_images/:id`).
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Registers a custom disk image and returns a presigned upload URL
  (`POST /v2/disk_images`).

  Upload the image file with a separate HTTP PUT to the returned URL.
  See the module documentation for required fields.
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params) do
    params
    |> Civo.require!([
      :name,
      :distribution,
      :version,
      :os,
      :region,
      :image_sha256,
      :image_md5,
      :image_size
    ])
    |> then(&Civo.post(@path, &1))
  end

  @doc """
  Deletes a custom disk image (`DELETE /v2/disk_images/:id`).
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end
end
