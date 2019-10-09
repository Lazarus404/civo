defmodule Civo.Charges do
  @moduledoc """
  The system tracks usage of paid service on an hourly basis. 
  It doesn't track how much to charge for any particular product, 
  but it will report for each instance, IP address and snapshot 
  the amount of hours it's in use for.
  """
  @doc """
  Get current charges for an account.

  Listing the charges for an Account must be done either with 
  an administrator API key and specifying the account_id in 
  question or using an API key from a user with 
  admin/billing-view permission.

  ### Request
  This request doesn't require any parameters, but you can specify 
  a time range (maximum of 31 days) with:

  | Name | Description |
  | ---- | ----------- |
  | `from` | The from date in RFC 3339 format (default to the start of the current month) |
  | `to` | The to date in RFC 3339 format (defaults to the current time) |

  ### Response
  The response from the server will be a list of chargeable resources. 
  The `size_gb` attribute currently only returns a value for volume 
  related charges as they as charged on a per GB basis as opposed to 
  hourly.

  ```elixir
  [
    {
      "code": "instance-g1.small",
      "label": "furry-apple.example.com",
      "from": "2016-03-18T10:46:06Z",
      "to": "2016-03-25T10:46:06Z",
      "num_hours": 168,
      "size_gb": null
    },
  ]
  ```
  """
  @spec list(String.t(), String.t()) :: Civo.Response.t() | Civo.Error.t()
  def list(from \\ nil, to \\ nil),
    do: Civo.get("charges", %{from: from, to: to})
end
