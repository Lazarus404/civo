defmodule Civo.InstancesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{Instances, Response}

  test "list available sizes" do
    use_cassette :stub,
      url: "~r/api.civo.com\/v2\/sizes/",
      method: "get",
      status_code: 200,
      body: ~s([{"name":"g3.small","cpu_cores":1}]) do
      assert %Response{body: [%{"name" => "g3.small"}]} = Instances.available_sizes()
    end
  end

  test "lists instances" do
    use_cassette :stub,
      url: "~r/api.civo.com\/v2\/instances/",
      method: "get",
      status_code: 200,
      body: ~s({"page":1,"items":[{"id":"i1","hostname":"h"}]}) do
      assert %Response{body: %{"items" => [%{"id" => "i1"}]}} = Instances.list()
    end
  end

  test "create an instance" do
    use_cassette :stub,
      url: "~r/api.civo.com\/v2\/instances/",
      method: "post",
      status_code: 200,
      body: ~s({"id":"i1","hostname":"test.example.com","status":"BUILDING"}) do
      data = %Instances{
        hostname: "test.example.com",
        size: "g3.small",
        network_id: "net-1",
        template_id: "img-1",
        region: "LON1"
      }

      assert %Response{body: %{"id" => "i1"}} = Instances.create(data)
    end
  end

  test "instance lifecycle actions" do
    stubs = [
      [url: "~r/hard_reboots/", method: "post", status_code: 200, body: ~s({"result":"success"})],
      [url: "~r/soft_reboots/", method: "post", status_code: 200, body: ~s({"result":"success"})],
      [url: "~r/stop/", method: "put", status_code: 200, body: ~s({"result":"success"})],
      [url: "~r/start/", method: "put", status_code: 200, body: ~s({"result":"success"})],
      [url: "~r/resize/", method: "put", status_code: 200, body: ~s({"result":"success"})],
      [url: "~r/firewall/", method: "put", status_code: 200, body: ~s({"result":"success"})],
      [url: "~r/tags/", method: "put", status_code: 200, body: ~s({"result":"success"})],
      [url: "~r/allowed_ips/", method: "put", status_code: 200, body: ~s({"result":"success"})],
      [
        url: "~r/network_bandwidth_limit/",
        method: "put",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [
        url: "~r/instances\/i1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [url: "~r/instances\/i1/", method: "get", status_code: 200, body: ~s({"id":"i1"})]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: %{"result" => "success"}} = Instances.hard_reboots("i1", "LON1")
      assert %Response{body: %{"result" => "success"}} = Instances.soft_reboots("i1", "LON1")
      assert %Response{body: %{"result" => "success"}} = Instances.stop("i1", "LON1")
      assert %Response{body: %{"result" => "success"}} = Instances.start("i1", "LON1")

      assert %Response{body: %{"result" => "success"}} =
               Instances.resize("i1", "g3.medium", "LON1")

      assert %Response{body: %{"result" => "success"}} = Instances.firewall("i1", "fw-1", "LON1")
      assert %Response{body: %{"result" => "success"}} = Instances.retag("i1", "web", "LON1")

      assert %Response{body: %{"result" => "success"}} =
               Instances.allowed_ips("i1", ["1.2.3.4"], "LON1")

      assert %Response{body: %{"result" => "success"}} =
               Instances.network_bandwidth_limit("i1", 10, "LON1")

      assert %Response{body: %{"result" => "success"}} = Instances.delete("i1", "LON1")
      assert %Response{body: %{"id" => "i1"}} = Instances.get("i1", "LON1")
    end
  end

  test "create raises without required fields" do
    assert_raise ArgumentError, ~r/hostname/, fn ->
      Instances.create(%Instances{size: "g3.small", network_id: "n", template_id: "t"})
    end
  end

  test "get raises without region" do
    Application.put_env(:civo, :region, nil)

    assert_raise ArgumentError, ~r/region/, fn ->
      Instances.get("i1")
    end
  end
end
