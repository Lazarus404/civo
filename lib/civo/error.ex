defmodule Civo.Error do
  @moduledoc """
  A struct representing a Civo API error.
  """
  defstruct error: nil, request: nil

  @type t :: %__MODULE__{}
end
