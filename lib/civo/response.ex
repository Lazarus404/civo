defmodule Civo.Response do
  @moduledoc """
  Successful Civo API response (`2xx`).

  ## Fields

  * `:body` — decoded JSON (map, list, or `nil` for empty bodies)
  * `:status` — HTTP status code
  * `:request` — the `Civo.Request` that was sent
  """

  alias Civo.Error

  @typedoc "A successful API response."
  @type t :: %__MODULE__{
          body: map() | list() | nil,
          status: integer(),
          request: Civo.Request.t() | nil
        }

  defstruct body: nil, status: 500, request: nil

  @doc """
  Converts an HTTPoison result into a `Civo.Response` or `Civo.Error`.

  Successful `2xx` bodies are decoded with Jason. Invalid JSON on 2xx
  becomes `%Civo.Error{kind: :decode}` (does not raise). Non-2xx and
  transport failures become `Civo.Error`.
  """
  @spec parse(
          {:ok, HTTPoison.Response.t() | HTTPoison.AsyncResponse.t()}
          | {:error, HTTPoison.Error.t()},
          any()
        ) ::
          __MODULE__.t() | Error.t()
  def parse({:ok, %HTTPoison.Response{body: body, status_code: status} = resp}, request)
      when status >= 200 and status < 300 do
    case decode_success(body) do
      {:ok, decoded} ->
        %__MODULE__{body: decoded, status: status, request: request}

      {:error, raw} ->
        %Error{
          kind: :decode,
          status: status,
          body: raw,
          error: resp,
          request: request
        }
    end
  end

  def parse({:ok, %HTTPoison.Response{body: body, status_code: status} = resp}, request) do
    decoded = decode_lossy(body)

    %Error{
      kind: :http,
      status: status,
      body: decoded,
      reason: extract_reason(decoded),
      error: resp,
      request: request
    }
  end

  def parse({:error, error}, request) do
    %Error{kind: :transport, error: error, request: request}
  end

  def parse(v), do: v

  defp decode_success(""), do: {:ok, nil}
  defp decode_success(nil), do: {:ok, nil}

  defp decode_success(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> {:ok, decoded}
      {:error, _} -> {:error, body}
    end
  end

  defp decode_lossy(""), do: nil
  defp decode_lossy(nil), do: nil

  defp decode_lossy(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> decoded
      {:error, _} -> body
    end
  end

  defp extract_reason(%{"reason" => r}) when is_binary(r), do: r
  defp extract_reason(%{"message" => m}) when is_binary(m), do: m
  defp extract_reason(%{"error" => e}) when is_binary(e), do: e
  defp extract_reason(_), do: nil
end
