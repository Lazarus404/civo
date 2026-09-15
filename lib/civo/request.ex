defmodule Civo.Request do
  @moduledoc """
  Metadata about the outbound HTTP call that produced a `Civo.Response`
  or `Civo.Error`.

  Attached for debugging; you do not build this struct yourself.
  """

  @typedoc """
  Request metadata.

  * `:method` — HTTP verb (`:get`, `:post`, `:put`, `:patch`, `:delete`)
  * `:url` — absolute URL without query string (path only base)
  * `:body` — JSON body string, or encoded query string for GET/DELETE
  """
  @type t :: %__MODULE__{
          method: atom() | nil,
          url: String.t() | nil,
          body: String.t() | nil
        }

  @doc false
  defstruct method: nil, url: nil, body: nil
end
