defmodule Civo.SSH do
  @moduledoc """
  To manage the SSH keys for an account that are used for 
  logging in to instances, there are a set of APIs for 
  listing the SSH public keys currently stored, as well 
  as adding and removing them by name.
  """
  defstruct name: nil, public_key: nil

  @type t :: %{
          name: String.t(),
          public_key: String.t()
        }

  @path "sshkeys"

  @doc """
  Lists all SSH keys in the account.

  ### Request
  This request doesn't take any parameters.

  ### Response
  The response from the server will be a list of the SSH keys known 
  for the current account holder.

  ```elixir
  [
    {
      "id": "730c960f-a51f-44e5-9c21-bd135d015d12",
      "name": "default",
      "fingerprint": "SHA256:181210f8f9c779c26da1d9b2075bde0127302ee0e3fca38c9a83f5b1dd8e5d3b"
    }
  ]
  ```
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Gets an SSH key instance.

  ### Request
  This request requires only the ID parameter.

  ### Response
  The response is a JSON object that describes the details for the SSH key.

  ```elixir
  {
    "id": "730c960f-a51f-44e5-9c21-bd135d015d12",
    "name": "default",
    "fingerprint": "SHA256:181210f8f9c779c26da1d9b2075bde0127302ee0e3fca38c9a83f5b1dd8e5d3b"
  }
  ```
  """
  @spec get(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def get(id),
    do:
      @path
      |> Path.join(id)
      |> Civo.get()

  @doc """
  Uploads a new SSH Key.

  ### Request
  The following parameter(s) should be sent along with the request:

  | Name  | Description |
  | ----- | ----------- |
  | `name`  | a string that will be the OpenStack reference for the SSH key. |
  | `public_key` | a string containing the SSH public key. |

  ### Response
  The response from the server will just be a confirmation of success 
  and the ID of the new key.

  ```elixir
  {
    "result": "success",
    "id": "730c960f-a51f-44e5-9c21-bd135d015d12",
  }
  ```
  """
  @spec upload(t()) :: Civo.Response.t() | Civo.Error.t()
  def upload(%__MODULE__{} = params),
    do: Civo.post(@path, params)

  @doc """
  Updates an existing SSH key.

  ### Request
  The following parameter(s) should be sent along with the request:

  | Name  | Description |
  | ----- | ----------- |
  | `id`  | the ID of the SSH key to update |
  | `name` | a string that will be the OpenStack reference for the SSH key. |

  ### Response
  The response from the server will be the updated SSH key.

  ```elixir
  [
    {
      "id": "730c960f-a51f-44e5-9c21-bd135d015d12",
      "name": "updated-name",
      "fingerprint": "SHA256:181210f8f9c779c26da1d9b2075bde0127302ee0e3fca38c9a83f5b1dd8e5d3b"
    }
  ]
  ```
  """
  @spec update(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def update(id, name),
    do:
      @path
      |> Path.join(id)
      |> Civo.put(%{name: name})

  @doc """
  Deletes an SSH key.

  The account holder can remove an SSH key attached to their account. 
  However, this only removes it from selection when creating instances, 
  it doesn't remove it from previously created instances. This should 
  be definitely confirmed by the user before any API call is made 
  because doing so will immediately remove the SSH key.

  ### Request
  This request takes the key name parameter.

  ### Response
  The response from the server will be a JSON block. The response will 
  include a result field and the HTTP status will be 202 Accepted.

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
