defmodule Civo.Networks do
  @moduledoc """
  To manage the private networks for an account, there are a 
  set of APIs for listing them, as well as adding, renaming 
  and removing them by ID.
  """
  @path "networks"

  @doc """
  Creates a new private network.

  ### Request
  The following parameter should be sent along with the request:

  | Name | Description |
  | ---- | ----------- |
  | `label` | a string that will be the displayed name/reference for the network. |

  ### Response
  The response from the server will just be a confirmation of success.

  ```elixir
  {
    "result": "success",
    "id": "50f2fffa-f81e-4e96-830f-e78f7e565e6f"
    "label": "development"
  }
  ```
  """
  @spec create(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def create(label),
    do: Civo.post(@path, %{label: label})

  @doc """
  Lists all available networks in an account.

  ### Request
  This request doesn't take any parameters.

  ### Response
  The response from the server will be a list of the SSH keys 
  known for the current account holder.

  ```elixir
  [
    {
      "id": "50f2fffa-f81e-4e96-830f-e78f7e565e6f",
      "name": "example-ltd-a775-development-75362452-562f-4b70-a65a-aeb4d4cd6864",
      "region": "lon1",
      "default": false,
      "cidr": "0.0.0.0/0",
      "label": "development"
    }
  ]
  ```
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Renames a private network.

  ### Request
  This request takes an id parameter of the network to rename and
  a label parameter which is the new label to use.

  ### Response
  The response from the server will be a JSON block. The response 
  will include a result field and the HTTP status will be 202 Accepted.

  ```elixir
  {
    "result": "success",
    "id": "50f2fffa-f81e-4e96-830f-e78f7e565e6f",
    "label": "development",
  }
  ```
  """
  @spec rename(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def rename(id, label),
    do:
      @path
      |> Path.join(id)
      |> Civo.put(%{label: label})

  @doc """
  The account holder can remove a private network, providing 
  there are no instances using it.

  ### Request
  This request takes an ID parameter.

  ### Response
  The response from the server will be a JSON block. The response 
  will include a result field and the HTTP status will be 202 Accepted.

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
