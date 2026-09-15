defmodule Civo.FirewallsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{Firewalls, Response}

  test "firewall and rules" do
    stubs = [
      [
        url: "~r/firewalls/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"f1","name":"fw"}])
      ],
      [
        url: "~r/firewalls/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"f1","name":"fw","result":"success"})
      ],
      [
        url: "~r/firewalls\/f1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"f1","name":"fw"})
      ],
      [
        url: "~r/firewalls\/f1/",
        method: "put",
        status_code: 200,
        body: ~s({"id":"f1","result":"success"})
      ],
      [
        url: "~r/rules/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"r1","start_port":"443"}])
      ],
      [
        url: "~r/rules/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"r1","start_port":"443"})
      ],
      [
        url: "~r/rules\/r1/",
        method: "put",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [
        url: "~r/rules\/r1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [
        url: "~r/firewalls\/f1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: [%{"id" => "f1"}]} = Firewalls.list("LON1")
      assert %Response{body: %{"id" => "f1"}} = Firewalls.create("fw", "net-1", "LON1")
      assert %Response{body: %{"id" => "f1"}} = Firewalls.get("f1", "LON1")

      assert %Response{body: %{"result" => "success"}} =
               Firewalls.update("f1", %{name: "fw2"}, "LON1")

      assert %Response{body: [%{"id" => "r1"}]} = Firewalls.rules("f1", "LON1")

      assert %Response{body: %{"id" => "r1"}} =
               Firewalls.create_rule("f1", %Firewalls{start_port: 443, region: "LON1"})

      assert %Response{body: %{"result" => "success"}} =
               Firewalls.update_rule("f1", "r1", %{label: "https"}, "LON1")

      assert %Response{body: %{"result" => "success"}} = Firewalls.delete_rule("f1", "r1", "LON1")
      assert %Response{body: %{"result" => "success"}} = Firewalls.delete("f1", "LON1")
    end
  end
end
