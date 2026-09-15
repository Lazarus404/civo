defmodule Civo.ObjectStores do
  @moduledoc """
  S3-compatible object stores (`/v2/objectstores`) and credentials
  (`/v2/objectstore/credentials`).

  Create a store, optionally create credentials, then use the returned
  access keys with any S3 client against Civo's object-store endpoint.

  ## Store create params

  | Key | Required | Description |
  | --- | --- | --- |
  | `:name` | yes | Store name |
  | `:region` | yes | Region code |
  | `:size` | no | Size in GB |
  | `:access_key_id` | no | Existing credential to attach |

  ## Credential create params

  | Key | Required | Description |
  | --- | --- | --- |
  | `:name` | yes | Credential name |
  | `:region` | yes | Region code |
  | `:access_key_id` | no | Custom access key |
  | `:secret_access_key_id` | no | Custom secret |
  | `:max_size_gb` | no | Max store size this credential may use |
  """

  @path "objectstores"
  @creds "objectstore/credentials"

  @doc """
  Creates an object store (`POST /v2/objectstores`).

  Required: `:name`, `:region`. Optional: `:size`, `:access_key_id`.
  """
  @spec create(map()) :: Civo.Response.t() | Civo.Error.t()
  def create(params) when is_map(params) do
    params
    |> Civo.require!([:name, :region])
    |> then(&Civo.post(@path, &1))
  end

  @doc """
  Lists object stores (`GET /v2/objectstores`).

  Typical keys: `:region`; optional `:page`, `:per_page`.
  """
  @spec list(map()) :: Civo.Response.t() | Civo.Error.t()
  def list(params \\ %{}) when is_map(params),
    do: Civo.get(@path, params)

  @doc """
  Fetches an object store by `id` (`GET /v2/objectstores/:id`).
  """
  @spec get(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Updates an object store (`PATCH /v2/objectstores/:id`).

  Commonly used to resize (`:size`) or rename.
  """
  @spec update(String.t(), map(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def update(id, params, region \\ nil) when is_map(params) do
    region = Civo.require_region!(region)

    @path
    |> Path.join(id)
    |> Civo.patch(Civo.region_params(region, params))
  end

  @doc """
  Deletes an object store (`DELETE /v2/objectstores/:id`).
  """
  @spec delete(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete(id, region \\ nil) do
    region = Civo.require_region!(region)
    @path |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end

  @doc """
  Creates object-store credentials (`POST /v2/objectstore/credentials`).

  Required: `:name`, `:region`. See module docs for optional keys.
  """
  @spec create_credential(map()) :: Civo.Response.t() | Civo.Error.t()
  def create_credential(params) when is_map(params) do
    params
    |> Civo.require!([:name, :region])
    |> then(&Civo.post(@creds, &1))
  end

  @doc """
  Lists object-store credentials (`GET /v2/objectstore/credentials`).
  """
  @spec list_credentials(map()) :: Civo.Response.t() | Civo.Error.t()
  def list_credentials(params \\ %{}) when is_map(params),
    do: Civo.get(@creds, params)

  @doc """
  Fetches credentials by `id` (`GET /v2/objectstore/credentials/:id`).
  """
  @spec get_credential(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def get_credential(id, region \\ nil) do
    region = Civo.require_region!(region)
    @creds |> Path.join(id) |> Civo.get(Civo.region_params(region))
  end

  @doc """
  Deletes credentials (`DELETE /v2/objectstore/credentials/:id`).
  """
  @spec delete_credential(String.t(), String.t() | nil) :: Civo.Response.t() | Civo.Error.t()
  def delete_credential(id, region \\ nil) do
    region = Civo.require_region!(region)
    @creds |> Path.join(id) |> Civo.delete(Civo.region_params(region))
  end
end
