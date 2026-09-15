defmodule Civo.SSH do
  @moduledoc """
  SSH public keys for instance login (`/v2/sshkeys`).

  Upload a key once, then pass its ID as `ssh_key_id` when creating
  instances via `Civo.Instances`.

  ## Create fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:name` | yes | Display name for the key |
  | `:public_key` | yes | OpenSSH public key string |
  """

  @typedoc "Parameters for uploading an SSH key."
  @type t :: %__MODULE__{
          name: String.t() | nil,
          public_key: String.t() | nil
        }

  defstruct name: nil, public_key: nil

  @path "sshkeys"

  @doc """
  Lists uploaded SSH keys (`GET /v2/sshkeys`).
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Fetches an SSH key by `id` (`GET /v2/sshkeys/:id`).
  """
  @spec get(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def get(id),
    do: @path |> Path.join(id) |> Civo.get()

  @doc """
  Uploads an SSH public key (`POST /v2/sshkeys`).
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params) do
    params
    |> Civo.require!([:name, :public_key])
    |> then(&Civo.post(@path, &1))
  end

  @doc """
  Updates an SSH key (`PUT /v2/sshkeys/:id`).

  Accepts a `t` struct or a map (typically `%{name: ...}`).
  """
  @spec update(String.t(), t() | map()) :: Civo.Response.t() | Civo.Error.t()
  def update(id, %__MODULE__{} = params),
    do: update(id, Map.from_struct(params))

  def update(id, params) when is_map(params) do
    @path
    |> Path.join(id)
    |> Civo.put(params)
  end

  @doc """
  Deletes an SSH key (`DELETE /v2/sshkeys/:id`).
  """
  @spec delete(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete(id),
    do: @path |> Path.join(id) |> Civo.delete()
end
