defmodule Civo.Response do
  alias Civo.Error

  defstruct body: nil, status: 500, request: nil

  @type t :: %__MODULE__{}

  @spec parse(
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()},
          any()
        ) ::
          __MODULE__.t() | Error.t()
  def parse({:ok, %HTTPoison.Response{body: body, status_code: status}}, request)
      when status >= 200 and status < 300,
      do: %__MODULE__{body: Poison.decode(body), status: status, request: request}

  def parse({:ok, resp}, request), do: %Error{error: resp, request: request}
  def parse({:error, error}, request), do: %Error{error: error, request: request}
  def parse(v), do: v
end
