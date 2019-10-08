defmodule Civo do
  alias Civo.Response
  alias Civo.Request

  def url(path),
    do:
      Path.join("https://api.civo.com/v2", path)
      |> Response.parse()

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

  def post(path, params \\ %{}, opts \\ []) do
    body = params |> clean() |> Poison.encode!()

    HTTPoison.post(url(path), body, auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :post, url: url(path), body: body})
  end

  def put(path, params \\ %{}, opts \\ []) do
    body = params |> clean() |> Poison.encode!()

    HTTPoison.put(url(path), body, auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :put, url: url(path), body: body})
  end

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
