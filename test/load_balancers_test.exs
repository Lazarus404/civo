defmodule Civo.LoadBalancersTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{LoadBalancers, Response}

  test "vpc load balancer CRUD" do
    stubs = [
      [
        url: "~r/loadbalancers/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"lb1","name":"my-lb"}])
      ],
      [
        url: "~r/loadbalancers/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"lb1","name":"my-lb"})
      ],
      [
        url: "~r/loadbalancers\/lb1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"lb1","name":"my-lb"})
      ],
      [
        url: "~r/loadbalancers\/lb1/",
        method: "put",
        status_code: 200,
        body: ~s({"id":"lb1","name":"updated"})
      ],
      [
        url: "~r/loadbalancers\/lb1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: [%{"id" => "lb1"}]} = LoadBalancers.list("LON1")

      data = %LoadBalancers{
        name: "my-lb",
        network_id: "net-1",
        region: "LON1",
        backends: [%{ip: "10.0.0.1", protocol: "TCP", source_port: 80, target_port: 80}]
      }

      assert %Response{body: %{"id" => "lb1"}} = LoadBalancers.create(data)
      assert %Response{body: %{"id" => "lb1"}} = LoadBalancers.get("lb1", "LON1")

      assert %Response{body: %{"name" => "updated"}} =
               LoadBalancers.update("lb1", %{name: "updated"}, "LON1")

      assert %Response{body: %{"result" => "success"}} = LoadBalancers.delete("lb1", "LON1")
    end
  end
end
