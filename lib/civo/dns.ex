defmodule Civo.DNS do
  @moduledoc """
  Civo host reverse DNS for all instances automatically. If you'd 
  like to manage forward (normal) DNS for your domains, you can do 
  that for free within your account.

  This API is effectively split in to two parts: 1) Managing domain 
  names themselves, and 2) Managing records within those domain names.

  Civo don't offer registration of domain names, this is purely for 
  hosting the DNS. If you're looking to buy a domain name, Civo 
  recommends [LCN.com](http://lcn.com) for their excellent friendly support and very 
  competitive prices.
  """
  #  the choice of RR type from a, cname, mx or txt
  defstruct type: nil,
            #  the portion before the domain name (e.g. www) or an @ for the apex/root domain (you cannot use an A record with an amex/root domain)
            name: nil,
            # the IP address (A or MX), hostname (CNAME or MX) or text value (TXT) to serve for this record
            value: nil,
            #  useful for MX records only, the priority mail should be attempted it (defaults to 10)
            priority: nil,
            # how long caching DNS servers should cache this record for, in seconds (the minimum is 600 and the default if unspecified is 600)
            ttl: nil

  @type t :: %{
          type: String.t(),
          name: String.t(),
          value: String.t(),
          priority: integer(),
          ttl: integer()
        }

  @path "dns"

  # ===============
  # Domain
  # ===============

  @doc """
  List all domains for an account.

  ### Request
  This request takes no parameters.

  ### Response
  The response is a JSON array of objects that lists each domain name.

  ```elixir
  [
    {
      "id": "7088fcea-7658-43e6-97fa-273f901978fd",
      "account_id": "e7e8386e-434e-482f-95e0-c406e5d564c2",
      "name": "example.com",
    }
  ]
  ```
  """
  @spec list_domains() :: Civo.Response.t() | Civo.Error.t()
  def list_domains(),
    do: Civo.get(@path)

  @doc """
  Create a domain from an account.

  Any user can add a domain name (that has been registered elsewhere) 
  to be managed by [Civo.com](http://civo.com). You should adjust the nameservers of 
  your domain (through your registrar) to point to `ns0.civo.com` and 
  `ns1.civo.com`.

  ### Request
  There is a single parameter.

  | Name | Description |
  | ---- | ----------- |
  | `name` | the domain name, e.g. "example.com" |

  ### Response
  The response is a JSON object that confirms the details given, with an id ready for you to add records to the domain.

  ```elixir
  {
    "result": "success",
    "id": "927ecdb9-90a3-4f3c-8280-1a1924da926a",
    "name": "example.com"
  }
  ```
  """
  @spec create_domain(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def create_domain(name),
    do: Civo.post(@path, %{name: name})

  @doc """
  Update a domain for an account.

  After creating a custom domain, any user can update their domain.

  ### Request
  The following parameters should be sent along with the request:

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the domain entry to update. |
  | `name` | the domain name, e.g. "example.com" |

  ### Response
  The response is a JSON object that simply confirms that the domain was updated.

  ```elixir
  {
    "result": "success",
    "id": "927ecdb9-90a3-4f3c-8280-1a1924da926a",
    "name": "myexample.com"
  }
  ```
  """
  @spec update_domain(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def update_domain(id, name),
    do:
      @path
      |> Path.join(id)
      |> Civo.put(%{name: name})

  @doc """
  Delete a domain from an account.

  An account holder can remove a domain, which will automically 
  remove all DNS records.

  ### Request
  This request takes the ID of the domain to 
  delete. No confirmation step is required, this step 
  will remove the domain and all records immediately.

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
  @spec delete_domain(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete_domain(id),
    do:
      @path
      |> Path.join(id)
      |> Civo.delete()

  # ===============
  # DNS
  # ===============

  @doc """
  List all DNS records for an account.

  ### Request
  This request takes no parameters.

  ### Response
  The response is a JSON array of objects that describes summary 
  details for each instance.

  ```elixir
  [
    {
      "id": "76cc107f-fbef-4e2b-b97f-f5d34f4075d3",
      "created_at": "2019-04-11T12:47:56.000+01:00",
      "updated_at": "2019-04-11T12:47:56.000+01:00",
      "account_id": null,
      "domain_id": "edc5dacf-a2ad-4757-41ee-c12f06259c70",
      "name": "mail",
      "value": "10.0.0.1",
      "type": "mx",
      "priority": 10,
      "ttl": 600
    }
  ]
  ```
  """
  @spec list_dns(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def list_dns(domain_id),
    do:
      Path.join([@path, domain_id, "records"])
      |> Civo.get()

  @doc """
  Create a DNS record in an account.

  An account holder can create DNS records for a specific domain.

  ### Request
  The following parameters are required for setting DNS records:

  | Name | Description |
  | ---- | ----------- |
  | `domain_id` | the id of the domain to use for the DNS. |
  | `type` | the choice of RR type from a, cname, mx or txt |
  | `name` | the portion before the domain name (e.g. www) or an @ for the apex/root domain (you cannot use an A record with an amex/root domain) |
  | `value` | the IP address (A or MX), hostname (CNAME or MX) or text value (TXT) to serve for this record |
  | `priority` | useful for MX records only, the priority mail should be attempted it (defaults to 10) |
  | `ttl` | how long caching DNS servers should cache this record for, in seconds (the minimum is 600 and the default if unspecified is 600) |

  ### Response
  The response is a JSON object that confirms the details given..

  ```elixir
  {
    "id": "76cc107f-fbef-4e2b-b97f-f5d34f4075d3",
    "created_at": "2019-04-11T12:47:56.000+01:00",
    "updated_at": "2019-04-11T12:47:56.000+01:00",
    "account_id": null,
    "domain_id": "edc5dacf-a2ad-4757-41ee-c12f06259c70",
    "name": "mail",
    "value": "10.0.0.1",
    "type": "mx",
    "priority": 10,
    "ttl": 600
  }
  ```
  """
  @spec create_dns(String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def create_dns(domain_id, %__MODULE__{} = params),
    do:
      Path.join([@path, domain_id, "records"])
      |> Civo.post(params)

  @doc """
  Update a DNS record for an account.

  After creating a DNS record, any user can update their DNS record.

  ### Request
  The following parameters should be sent along with the request:

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the DNS entry to update. |
  | `domain_id` | the id of the domain to use for the DNS. |
  | `type` | the choice of RR type from a, cname, mx or txt |
  | `name` | the portion before the domain name (e.g. www) or an @ for the apex/root domain (you cannot use an A record with an amex/root domain) |
  | `value` | the IP address (A or MX), hostname (CNAME or MX) or text value (TXT) to serve for this record |
  | `priority` | useful for MX records only, the priority mail should be attempted it (defaults to 10) |
  | `ttl` | how long caching DNS servers should cache this record for, in seconds (the minimum is 600 and the default if unspecified is 600) |

  ### Response
  The response is a JSON object that simply confirms that the DNS 
  record was updated.

  ```elixir
  {
    "id": "76cc107f-fbef-4e2b-b97f-f5d34f4075d3",
    "created_at": "2019-04-11T12:47:56.000+01:00",
    "updated_at": "2019-04-11T12:47:56.000+01:00",
    "account_id": null,
    "domain_id": "edc5dacf-a2ad-4757-41ee-c12f06259c70",
    "name": "email",
    "value": "10.0.0.1",
    "type": "mx",
    "priority": 10,
    "ttl": 600
  }
  ```
  """
  @spec update_dns(String.t(), String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def update_dns(id, domain_id, %__MODULE__{} = params),
    do:
      Path.join([@path, domain_id, "records", id])
      |> Civo.put(params)

  @doc """
  Delete a DNS record from an account.

  An account holder can remove a DNS record from a domain.

  ### Request
  This request takes the ID of the DNS record to 
  delete and the ID of the domain. No confirmation 
  step is required, this step will remove the DNS record 
  immediately.

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
  @spec delete_dns(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete_dns(id, domain_id),
    do:
      Path.join([@path, domain_id, "records", id])
      |> Civo.delete()
end
