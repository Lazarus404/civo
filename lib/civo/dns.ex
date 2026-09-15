defmodule Civo.DNS do
  @moduledoc """
  Forward DNS domains and records (`/v2/dns`).

  Domains are managed at `/v2/dns`; records live under
  `/v2/dns/:domain_id/records`. Supported record types: `a`, `cname`,
  `mx`, `txt`.

  ## Record fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:type` | yes | `"a"`, `"cname"`, `"mx"`, or `"txt"` |
  | `:name` | yes | Relative or absolute hostname |
  | `:value` | yes | Record value (IP, hostname, or text) |
  | `:priority` | for MX | MX priority |
  | `:ttl` | no | Time to live in seconds |
  """

  @typedoc "Parameters for creating or updating a DNS record."
  @type t :: %__MODULE__{
          type: String.t() | nil,
          name: String.t() | nil,
          value: String.t() | nil,
          priority: integer() | nil,
          ttl: integer() | nil
        }

  defstruct type: nil,
            name: nil,
            value: nil,
            priority: nil,
            ttl: nil

  @path "dns"

  @doc """
  Lists DNS domains for the account (`GET /v2/dns`).
  """
  @spec list_domains() :: Civo.Response.t() | Civo.Error.t()
  def list_domains(),
    do: Civo.get(@path)

  @doc """
  Creates a DNS domain (`POST /v2/dns`).

  `name` is the apex domain (e.g. `"example.com"`).
  """
  @spec create_domain(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def create_domain(name),
    do: Civo.post(@path, %{name: name})

  @doc """
  Renames a DNS domain (`PUT /v2/dns/:id`).
  """
  @spec update_domain(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def update_domain(id, name) do
    @path
    |> Path.join(id)
    |> Civo.put(%{name: name})
  end

  @doc """
  Deletes a DNS domain and its records (`DELETE /v2/dns/:id`).
  """
  @spec delete_domain(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete_domain(id),
    do: @path |> Path.join(id) |> Civo.delete()

  @doc """
  Lists DNS records for a domain (`GET /v2/dns/:domain_id/records`).
  """
  @spec list_dns(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def list_dns(domain_id) do
    Path.join([@path, domain_id, "records"])
    |> Civo.get()
  end

  @doc """
  Creates a DNS record (`POST /v2/dns/:domain_id/records`).

  See the module documentation for fields on `t`.
  """
  @spec create_dns(String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def create_dns(domain_id, %__MODULE__{} = params) do
    params = Civo.require!(params, [:type, :name, :value])

    Path.join([@path, domain_id, "records"])
    |> Civo.post(params)
  end

  @doc """
  Updates a DNS record (`PUT /v2/dns/:domain_id/records/:id`).
  """
  @spec update_dns(String.t(), String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def update_dns(domain_id, id, %__MODULE__{} = params) do
    Path.join([@path, domain_id, "records", id])
    |> Civo.put(params)
  end

  @doc """
  Deletes a DNS record (`DELETE /v2/dns/:domain_id/records/:id`).
  """
  @spec delete_dns(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete_dns(domain_id, id) do
    Path.join([@path, domain_id, "records", id])
    |> Civo.delete()
  end
end
