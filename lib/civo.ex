defmodule Civo do
  @moduledoc """
  This is a utility module that performs all of the actual
  HTTP CRUD requests to the Civo API. It is not intended
  to work with this module directly.
  """
  alias Civo.Response
  alias Civo.Request

  @doc """
  Creates a full URL from an API path.
  """
  @spec url(String.t()) :: String.t()
  def url(path),
    do:
      Path.join("https://api.civo.com/v2", path)

  @doc """
  Performs an HTTP GET. Params are converted
  to query parameters.
  """
  @spec get(String.t(), map(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def get(path, params \\ %{}, opts \\ []) do
    body = params |> clean() |> URI.encode_query()

    res =
      path
      |> url()
      |> URI.parse()
      |> Map.put(:query, body)
      |> URI.to_string()

    res
    |> HTTPoison.get(auth_header(), opts)
    |> Response.parse(%Request{method: :get, url: url(path), body: body})
  end

  @doc """
  Performs an HTTP POST. Params are passed as
  a JSON body to the request
  """
  @spec post(String.t(), map(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def post(path, params \\ %{}, opts \\ []) do
    body = params |> clean() |> Poison.encode!()

    HTTPoison.post(url(path), body, auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :post, url: url(path), body: body})
  end

  @doc """
  Performs an HTTP PUT. Params are passed as
  a JSON body to the request
  """
  @spec put(String.t(), map(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def put(path, params \\ %{}, opts \\ []) do
    body = params |> clean() |> Poison.encode!()

    HTTPoison.put(url(path), body, auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :put, url: url(path), body: body})
  end

  @doc """
  Performs an HTTP DELETE. No parameters are
  accepted
  """
  @spec delete(String.t(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete(path, opts \\ []) do
    HTTPoison.delete(url(path), auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :delete, url: url(path)})
  end

  defp auth_header(),
    do: [{"authorization", "Bearer #{auth_token()}"}]

  defp json_header(),
    do: [{"content-type", "application/json"}]

  defp auth_token(),
    do: Application.get_env(:civo, :api_token)

  defp clean(%_{} = params),
    do:
      params
      |> Map.from_struct()

  defp clean(params),
    do: params
end
