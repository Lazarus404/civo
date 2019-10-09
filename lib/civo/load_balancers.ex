defmodule Civo.LoadBalancers do
  @moduledoc """
  If you want to create a load balancer for your instances, to 
  spread your web traffic between them then you can easily launch 
  a managed load balancer service on Civo. The pricing is described 
  on their pricing page.
  """
  #  the hostname to receive traffic for, e.g. "www.example.com" (optional: sets hostname to loadbalancer-uuid.civo.com if blank)
  defstruct hostname: nil,
            #  either http or https. If you specify https then you must also provide the next two fields, the default is "http"
            protocol: nil,
            # if your protocol is https then you should send the TLS certificate in Base64-encoded PEM format
            tls_certificate: nil,
            # if your protocol is https then you should send the TLS private key in Base64-encoded PEM format
            tls_key: nil,
            #  you can listen on any port, the default is "80" to match the default protocol of "http", if not you must specify it here (commonly 80 for HTTP or 443 for HTTPS)
            port: "80",
            #  the size in megabytes of the maximum request content that will be accepted, defaults to 20
            max_request_size: 20,
            #  one of: least_conn (sends new requests to the least busy server), random (sends new requests to a random backend), round_robin (sends new requests to the next backend in order), ip_hash (sends requests from a given IP address to the same backend), default is "random"
            policy: :random,
            # what URL should be used on the backends to determine if it's OK (2xx/3xx status), defaults to "/"
            health_check_path: "/",
            #  how long to wait in seconds before determining a backend has failed, defaults to 30
            fail_timeout: 30,
            # how many concurrent connections can each backend handle, defaults to 10
            max_conns: 10,
            #  should self-signed/invalid certificates be ignored from the backend servers, defaults to true
            ignore_invalid_backend_tls: true,
            #  a list of backend instances, each containing an instance_id, protocol (http or https) and port
            backends: nil

  @type t :: %{
          hostname: String.t(),
          protocol: String.t(),
          tls_certificate: String.t(),
          tls_key: String.t(),
          port: String.t(),
          max_request_size: integer(),
          policy: atom(),
          health_check_path: String.t(),
          fail_timeout: integer(),
          max_conns: integer(),
          ignore_invalid_backend_tls: boolean(),
          backends: list()
        }

  @path "loadbalancers"

  @doc """
  List all load balancers for an account.

  ### Request
  This request takes no parameters.

  ### Response
  The response is a JSON array of objects that describes each load balancer.

  ```elixir
  [
    {
      id: "542e9eca-539d-45e6-b629-2f905d0b5f93"
      hostname: "www.example.com",
      protocol: "https",
      port: "443",
      max_request_size: 20,
      tls_certificate: "...base64-encoded...",
      tls_key: "...base64-encoded...",
      policy: "random",
      health_check_path: "/",
      fail_timeout: 30,
      max_conns: 10,
      ignore_invalid_backend_tls: true,
      backends: [
        {
          instance_id: "82ef8d8e-688c-4fc3-a31c-41746f27b074",
          protocol: "http",
          port: 3000
        }
      ]
    }
  ]
  ```
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Create a load balancer for an account.

  Any user can create a load balancer service to be managed by 
  Civo.com. You should point a `CNAME` record for the hostname to 
  `lb.civo.com`. If you are using a root/apex/named domain then 
  you should use the list of IP addresses: `185.136.232.141`, 
  `185.136.233.100`, `185.136.233.118`, `185.136.233.131`, 
  `185.136.233.140`.

  ### Request
  The following parameters should be sent

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the load balancer |
  | `hostname` | the hostname to receive traffic for, e.g. "www.example.com" (optional: sets hostname to loadbalancer-uuid.civo.com if blank) |
  | `protocol` | either http or https. If you specify https then you must also provide the next two fields, the default is "http" |
  | `tls_certificate` | if your protocol is https then you should send the TLS certificate in Base64-encoded PEM format |
  | `tls_key` | if your protocol is https then you should send the TLS private key in Base64-encoded PEM format |
  | `port` | you can listen on any port, the default is "80" to match the default protocol of "http", if not you must specify it here (commonly 80 for HTTP or 443 for HTTPS) |
  | `max_request_size` | the size in megabytes of the maximum request content that will be accepted, defaults to 20 |
  | `policy` | one of: least_conn (sends new requests to the least busy server), random (sends new requests to a random backend), round_robin (sends new requests to the next backend in order), ip_hash (sends requests from a given IP address to the same backend), default is "random" |
  | `health_check_path` | what URL should be used on the backends to determine if it's OK (2xx/3xx status), defaults to "/" |
  | `fail_timeout` | how long to wait in seconds before determining a backend has failed, defaults to 30 |
  | `max_conns` | how many concurrent connections can each backend handle, defaults to 10 |
  | `ignore_invalid_backend_tls` | should self-signed/invalid certificates be ignored from the backend servers, defaults to true |
  | `backends` | a list of backend instances, each containing an instance_id, protocol (http or https) and port |

  ### Response
  The response is a JSON object that confirms the details given.

  ```elixir
  {
    id: "542e9eca-539d-45e6-b629-2f905d0b5f93"
    default_hostname: false,
    hostname: "www.example.com",
    protocol: "https",
    port: "443",
    max_request_size: 20,
    tls_certificate: "...base64-encoded...",
    tls_key: "...base64-encoded...",
    policy: "random",
    health_check_path: "/",
    fail_timeout: 30,
    max_conns: 10,
    ignore_invalid_backend_tls: true,
    backends: [
      {
        instance_id: "82ef8d8e-688c-4fc3-a31c-41746f27b074",
        protocol: "http",
        port: 3000
      }
    ]
  }
  ```
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params),
    do: Civo.post(@path, params)

  @doc """
  Update a load balancer for an account.

  Updating a load balancer takes exactly the same parameters 
  as setting up a load balancer

  ### Request
  The following parameters should be sent

  | Name | Description |
  | ---- | ----------- |
  | `id` | the id of the load balancer |
  | `hostname` | the hostname to receive traffic for, e.g. "www.example.com" (optional: sets hostname to loadbalancer-uuid.civo.com if blank) |
  | `protocol` | either http or https. If you specify https then you must also provide the next two fields, the default is "http" |
  | `tls_certificate` | if your protocol is https then you should send the TLS certificate in Base64-encoded PEM format |
  | `tls_key` | if your protocol is https then you should send the TLS private key in Base64-encoded PEM format |
  | `port` | you can listen on any port, the default is "80" to match the default protocol of "http", if not you must specify it here (commonly 80 for HTTP or 443 for HTTPS) |
  | `max_request_size` | the size in megabytes of the maximum request content that will be accepted, defaults to 20 |
  | `policy` | one of: least_conn (sends new requests to the least busy server), random (sends new requests to a random backend), round_robin (sends new requests to the next backend in order), ip_hash (sends requests from a given IP address to the same backend), default is "random" |
  | `health_check_path` | what URL should be used on the backends to determine if it's OK (2xx/3xx status), defaults to "/" |
  | `fail_timeout` | how long to wait in seconds before determining a backend has failed, defaults to 30 |
  | `max_conns` | how many concurrent connections can each backend handle, defaults to 10 |
  | `ignore_invalid_backend_tls` | should self-signed/invalid certificates be ignored from the backend servers, defaults to true |
  | `backends` | a list of backend instances, each containing an instance_id, protocol (http or https) and port |

  ### Response
  The response is a JSON object that confirms the details given.

  ```elixir
  {
    id: "542e9eca-539d-45e6-b629-2f905d0b5f93"
    default_hostname: false,
    hostname: "www.example.com",
    protocol: "https",
    port: "443",
    max_request_size: 20,
    tls_certificate: "...base64-encoded...",
    tls_key: "...base64-encoded...",
    policy: "random",
    health_check_path: "/",
    fail_timeout: 30,
    max_conns: 10,
    ignore_invalid_backend_tls: true,
    backends: [
      {
        instance_id: "82ef8d8e-688c-4fc3-a31c-41746f27b074",
        protocol: "http",
        port: 3000
      }
    ]
  }
  ```
  """
  @spec update(String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def update(id, %__MODULE__{} = params),
    do:
      @path
      |> Path.join(id)
      |> Civo.put(params)

  @doc """
  Delete a load balancer from an account.

  An account holder can remove a load balancer, which will within 
  one minute stop serving traffic for that hostname.

  ### Request
  This request takes the ID of the load balancer to delete. No 
  confirmation step is required, this step will remove the 
  load balancer.

  ### Response
  The response from the server will be a JSON block. The response will include a result field and the HTTP status will be 202 Accepted.

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
