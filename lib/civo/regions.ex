defmodule Civo.Regions do
  @moduledoc """
  Civo will be hosted in multiple datacentres (a.k.a. regions), 
  with more coming online all the time. You can choose when 
  creating an instance which region to have it hosted in 
  (necessary if you want to share a private network between 
  your instances) - or you can leave it for Civo to allocate 
  you to a region if you don't care.
  """
  @doc """
  List all available regions in Civo.

  ### Request
  This request doesn't take any parameters.

  ### Response
  The response from the server will be a JSON array of regions.

  ```elixir
  [
    {
      "code":"lon1",
    },
    // ...
  ]
  ```
  """
  @spec available_regions() :: Civo.Response.t() | Civo.Error.t()
  def available_regions(),
    do: Civo.get("regions")
end
