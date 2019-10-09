defmodule Civo.Request do
  @moduledoc """
  A struct representing a Civo API request. This
  module is not used directly, but intended
  for typing purposes in a response object.
  """
  defstruct method: nil, url: nil, body: nil

  @type t :: %__MODULE__{}
end
