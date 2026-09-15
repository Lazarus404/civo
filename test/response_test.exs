defmodule Civo.ResponseTest do
  use ExUnit.Case, async: true

  alias Civo.{Error, Request, Response}

  @req %Request{method: :get, url: "https://api.civo.com/v2/x", body: ""}

  test "parses 2xx JSON body" do
    raw = {:ok, %HTTPoison.Response{status_code: 200, body: ~s({"a":1})}}
    assert %Response{body: %{"a" => 1}, status: 200} = Response.parse(raw, @req)
  end

  test "empty 2xx body is nil" do
    raw = {:ok, %HTTPoison.Response{status_code: 204, body: ""}}
    assert %Response{body: nil, status: 204} = Response.parse(raw, @req)
  end

  test "invalid 2xx JSON becomes decode error" do
    raw = {:ok, %HTTPoison.Response{status_code: 200, body: "not-json"}}
    assert %Error{kind: :decode, status: 200, body: "not-json"} = Response.parse(raw, @req)
  end

  test "4xx JSON populates reason" do
    raw = {:ok, %HTTPoison.Response{status_code: 403, body: ~s({"reason":"denied"})}}

    assert %Error{kind: :http, status: 403, reason: "denied", body: %{"reason" => "denied"}} =
             Response.parse(raw, @req)
  end

  test "4xx non-JSON keeps string body" do
    raw = {:ok, %HTTPoison.Response{status_code: 404, body: "Not Found"}}
    assert %Error{kind: :http, status: 404, body: "Not Found"} = Response.parse(raw, @req)
  end

  test "transport error" do
    err = %HTTPoison.Error{reason: :timeout}
    assert %Error{kind: :transport, error: ^err} = Response.parse({:error, err}, @req)
  end
end
