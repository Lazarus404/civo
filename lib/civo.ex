defmodule Civo do
  @moduledoc """
  Low-level HTTP client for the [Civo](https://www.civo.com) API (`https://api.civo.com/v2`).

  Resource modules (`Civo.Instances`, `Civo.Kubernetes`, …) call this module.
  You normally configure credentials and use those modules instead.

  ## Configuration

      config :civo,
        api_token: "your-api-key",
        region: "LON1"   # optional default region

  When `:region` is set, it is merged into request params unless the caller
  already supplied one. Prefer an explicit `region` argument on resource
  functions when operating across multiple regions.

  Mutating requests (`POST` / `PUT` / `PATCH`) send `region` as a query
  parameter (like the official clients) and keep it in the JSON body when
  present, matching Civo create/update examples.

  ## Authentication

  Every request sends `Authorization: Bearer <api_token>`. Missing or blank
  `api_token` raises `ArgumentError`. You can also exchange the API key for
  a short-lived JWT with `exchange_token/1`.
  """

  alias Civo.Response
  alias Civo.Request

  @doc """
  Builds an absolute Civo v2 URL from a relative API path.

  ## Examples

      iex> Civo.url("instances")
      "https://api.civo.com/v2/instances"
  """
  @spec url(String.t()) :: String.t()
  def url(path),
    do: Path.join("https://api.civo.com/v2", path)

  @doc """
  Raises unless `config :civo, :api_token` is a non-empty string.
  """
  @spec require_token!() :: :ok
  def require_token! do
    case auth_token() do
      t when is_binary(t) and t != "" -> :ok
      _ -> raise ArgumentError, "config :civo, :api_token is required"
    end
  end

  @doc """
  Raises unless all `keys` are present and non-empty on `map` (or struct).

  Returns the original map/struct for piping.
  """
  @spec require!(map() | struct(), [atom()]) :: map() | struct()
  def require!(%_{} = struct, keys) do
    struct |> Map.from_struct() |> require!(keys)
    struct
  end

  def require!(map, keys) when is_map(map) and is_list(keys) do
    Enum.each(keys, fn key ->
      val = Map.get(map, key) || Map.get(map, Atom.to_string(key))

      if is_nil(val) or val == "" do
        raise ArgumentError, "missing required field: #{key}"
      end
    end)

    map
  end

  @doc """
  Returns a non-empty region from `region` or `config :civo, :region`.

  Raises `ArgumentError` when neither is set.
  """
  @spec require_region!(String.t() | nil) :: String.t()
  def require_region!(region) do
    case region || default_region() do
      r when is_binary(r) and r != "" -> r
      _ -> raise ArgumentError, "region is required (argument or config :civo, :region)"
    end
  end

  @doc false
  @spec split_region(map() | struct()) :: {map(), map()}
  def split_region(params) do
    # Match civogo: region on the query string and still in the JSON body when set.
    body = params |> clean() |> drop_nils() |> maybe_put_region()
    region = Map.get(body, :region) || Map.get(body, "region")

    query =
      case region do
        r when is_binary(r) and r != "" -> %{region: r}
        _ -> %{}
      end

    {body, query}
  end

  @doc """
  Performs an HTTP GET.

  `params` are encoded as the query string. Nil values are dropped. If
  neither `params` nor app config supply a region, none is sent.
  """
  @spec get(String.t(), map(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def get(path, params \\ %{}, opts \\ []) do
    require_token!()
    query = params |> prepare() |> encode_query()
    full = path |> url() |> with_query(query)

    full
    |> HTTPoison.get(auth_header(), opts)
    |> Response.parse(%Request{method: :get, url: url(path), body: query})
  end

  @doc """
  Performs an HTTP POST with a JSON body.

  `region` is sent as a query parameter and kept in the JSON body when set.
  """
  @spec post(String.t(), map(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def post(path, params \\ %{}, opts \\ []) do
    require_token!()
    {body_map, query_map} = split_region(params)
    body = Jason.encode!(body_map)
    full = path |> url() |> with_query(encode_query(query_map))

    HTTPoison.post(full, body, auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :post, url: url(path), body: body})
  end

  @doc """
  Performs an HTTP PUT with a JSON body.

  Same region/body handling as `post/3`.
  """
  @spec put(String.t(), map(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def put(path, params \\ %{}, opts \\ []) do
    require_token!()
    {body_map, query_map} = split_region(params)
    body = Jason.encode!(body_map)
    full = path |> url() |> with_query(encode_query(query_map))

    HTTPoison.put(full, body, auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :put, url: url(path), body: body})
  end

  @doc """
  Performs an HTTP PATCH with a JSON body.

  Same region/body handling as `post/3`.
  """
  @spec patch(String.t(), map(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def patch(path, params \\ %{}, opts \\ []) do
    require_token!()
    {body_map, query_map} = split_region(params)
    body = Jason.encode!(body_map)
    full = path |> url() |> with_query(encode_query(query_map))

    HTTPoison.patch(full, body, auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :patch, url: url(path), body: body})
  end

  @doc """
  Performs an HTTP DELETE.

  `params` become the query string (used for `region` on most delete calls).
  """
  @spec delete(String.t(), map(), Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete(path, params \\ %{}, opts \\ []) do
    require_token!()
    query = params |> prepare() |> encode_query()
    full = path |> url() |> with_query(query)

    full
    |> HTTPoison.delete(auth_header() ++ json_header(), opts)
    |> Response.parse(%Request{method: :delete, url: url(path), body: query})
  end

  @doc """
  Exchanges the configured API key for a short-lived JWT.

  Calls `POST /v2/auth/exchange`. The response body typically includes
  `access_token`, `refresh_token`, `expires_in`, and related fields.
  """
  @spec exchange_token(Keyword.t()) :: Civo.Response.t() | Civo.Error.t()
  def exchange_token(opts \\ []),
    do: post("auth/exchange", %{}, opts)

  @doc """
  Returns `params` with a `:region` key set.

  Precedence: existing `:region` / `"region"` in `params`, then `region`
  argument, then `config :civo, :region`.
  """
  @spec region_params(String.t() | nil, map()) :: map()
  def region_params(region \\ nil, params \\ %{}) do
    case Map.get(params, :region) || Map.get(params, "region") || region || default_region() do
      nil -> params
      r -> Map.put(params, :region, r)
    end
  end

  defp prepare(params) do
    params
    |> clean()
    |> drop_nils()
    |> maybe_put_region()
  end

  defp maybe_put_region(params) do
    cond do
      Map.has_key?(params, :region) or Map.has_key?(params, "region") ->
        params

      region = default_region() ->
        Map.put(params, :region, region)

      true ->
        params
    end
  end

  defp default_region(),
    do: Application.get_env(:civo, :region)

  defp with_query(base, ""), do: base

  defp with_query(base, query) do
    base
    |> URI.parse()
    |> Map.put(:query, query)
    |> URI.to_string()
  end

  defp encode_query(params) when map_size(params) == 0, do: ""

  defp encode_query(params) do
    params
    |> Enum.map(fn {k, v} -> {to_string(k), stringify(v)} end)
    |> URI.encode_query()
  end

  defp stringify(v) when is_list(v), do: Enum.join(v, ",")
  defp stringify(v), do: to_string(v)

  defp auth_header(),
    do: [{"authorization", "Bearer #{auth_token()}"}]

  defp json_header(),
    do: [{"content-type", "application/json"}]

  defp auth_token(),
    do: Application.get_env(:civo, :api_token)

  defp clean(%_{} = params),
    do: params |> Map.from_struct()

  defp clean(params) when is_map(params),
    do: params

  defp drop_nils(params) do
    params
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
