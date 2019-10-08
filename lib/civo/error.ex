defmodule Civo.Error do
  defstruct error: nil, request: nil

  @type t :: %__MODULE__{}
end
