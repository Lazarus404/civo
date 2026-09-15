defmodule Civo.IPsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{IPs, Response}

  test "list and create reserved IP" do
    stubs = [
      [
        url: "https://api.civo.com/v2/ips?region=LON1",
        method: "get",
        status_code: 200,
        body: ~s({"items":[{"id":"ip1","ip":"1.2.3.4"}]})
      ],
      [
        url: "https://api.civo.com/v2/ips?region=LON1",
        method: "post",
        status_code: 200,
        body: ~s({"id":"ip1","name":"my-ip"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: %{"items" => [%{"id" => "ip1"}]}} = IPs.list(%{region: "LON1"})
      assert %Response{body: %{"id" => "ip1"}} = IPs.create("my-ip", "LON1")
    end
  end

  test "assign and unassign reserved IP" do
    stubs = [
      [
        url: "~r/ips\\/ip1\\/actions/",
        method: "post",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [
        url: "~r/ips\\/ip1\\/actions/",
        method: "post",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: %{"result" => "success"}} = IPs.assign("ip1", "instance-1", "LON1")
      assert %Response{body: %{"result" => "success"}} = IPs.unassign("ip1", "LON1")
    end
  end

  test "get update delete reserved IP" do
    stubs = [
      [
        url: "~r/ips\\/ip1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"ip1","ip":"1.2.3.4"})
      ],
      [
        url: "~r/ips\\/ip1/",
        method: "put",
        status_code: 200,
        body: ~s({"id":"ip1","name":"renamed"})
      ],
      [
        url: "~r/ips\\/ip1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: %{"ip" => "1.2.3.4"}} = IPs.get("ip1", "LON1")

      assert %Response{body: %{"name" => "renamed"}} =
               IPs.update("ip1", %{name: "renamed"}, "LON1")

      assert %Response{body: %{"result" => "success"}} = IPs.delete("ip1", "LON1")
    end
  end
end
