defmodule Civo.Error do
  @moduledoc """
  Failed Civo API call (non-2xx HTTP response, transport error, or decode failure).

  ## Fields

  * `:kind` — `:http`, `:transport`, or `:decode`
  * `:status` — HTTP status when known
  * `:body` — decoded JSON, raw string if not JSON, or `nil`
  * `:reason` — best-effort message from the API body
  * `:error` — underlying `HTTPoison.Response` or `HTTPoison.Error`
  * `:request` — the `Civo.Request` that was attempted
  """

  @typedoc "An API, transport, or decode error."
  @type t :: %__MODULE__{
          kind: :http | :transport | :decode | nil,
          status: integer() | nil,
          body: term(),
          reason: String.t() | nil,
          error: term(),
          request: Civo.Request.t() | nil
        }

  defstruct kind: nil,
            status: nil,
            body: nil,
            reason: nil,
            error: nil,
            request: nil
end
