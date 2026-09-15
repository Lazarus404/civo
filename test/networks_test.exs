defmodule Civo.NetworksTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{Networks, Response}

  test "lists networks" do
    use_cassette :stub,
      url: "~r/api.civo.com\/v2\/networks/",
      method: "get",
      status_code: 200,
      body: ~s([{"id":"1","label":"Default","default":true}]) do
      assert %Response{status: 200, body: [%{"label" => "Default"}]} = Networks.list()
    end
  end

  test "create network" do
    use_cassette :stub,
      url: "~r/api.civo.com\/v2\/networks/",
      method: "post",
      status_code: 200,
      body: ~s({"result":"success","id":"1","label":"test"}) do
      assert %Response{body: %{"result" => "success"}} = Networks.create("test")
    end
  end

  test "rename network" do
    use_cassette :stub,
      url: "~r/api.civo.com\/v2\/networks/",
      method: "put",
      status_code: 200,
      body: ~s({"result":"success","label":"other"}) do
      assert %Response{body: %{"label" => "other"}} = Networks.rename("1", "other", "LON1")
    end
  end

  test "delete network" do
    use_cassette :stub,
      url: "~r/api.civo.com\/v2\/networks/",
      method: "delete",
      status_code: 200,
      body: ~s({"result":"success"}) do
      assert %Response{body: %{"result" => "success"}} = Networks.delete("1", "LON1")
    end
  end

  test "get network" do
    use_cassette :stub,
      url: "~r/api.civo.com\/v2\/networks/",
      method: "get",
      status_code: 200,
      body: ~s({"id":"1","label":"Default"}) do
      assert %Response{body: %{"id" => "1"}} = Networks.get("1", "LON1")
    end
  end
end
