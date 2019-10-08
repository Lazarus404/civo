defmodule Civo.Request do
  defstruct method: nil, url: nil, body: nil

  @type t :: %__MODULE__{}
end
