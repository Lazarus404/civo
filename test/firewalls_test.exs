defmodule Civo.FirewallsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Firewalls, Request, Response}
  doctest Firewalls

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/firewalls")
    :ok
  end

  test "create firewall" do
    resp =
      use_cassette "create firewall" do
        Firewalls.create("test")
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => "3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a",
                  "name" => "test",
                  "result" => "success"
                }},
             request: %Request{
               body: "{\"name\":\"test\"}",
               method: :post,
               url: "https://api.civo.com/v2/firewalls"
             },
             status: 200
           } = resp
  end

  test "list available firewalls" do
    resp =
      use_cassette "list firewalls" do
        Firewalls.list()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "id" => "65233d15-cb74-460e-a372-71853bb6e263",
                    "instances_count" => 0,
                    "name" => "test",
                    "openstack_security_group_id" => _,
                    "region" => "lon1",
                    "rules_count" => 0
                  }
                  | _
                ]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/firewalls"
             },
             status: 200
           } = resp
  end

  test "delete firewall" do
    resp =
      use_cassette "delete firewall" do
        Firewalls.delete("3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url: "https://api.civo.com/v2/firewalls/3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a"
             },
             status: 200
           } = resp
  end

  test "get firewall rules" do
    resp =
      use_cassette "get firewall rules" do
        Firewalls.rules("3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a")
      end

    assert %Response{
             body: {:ok, []},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/firewalls/3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a/rules"
             },
             status: 200
           } = resp
  end

  test "create firewall rules" do
    data = %Firewalls{
      protocol: "tcp",
      start_port: 4000,
      end_port: 4040,
      cidr: "0.0.0.0/0",
      direction: "inbound",
      label: "test rule"
    }

    resp =
      use_cassette "create firewall rule" do
        Firewalls.rules("3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a", data)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "cidr" => ["0.0.0.0/0"],
                  "direction" => "inbound",
                  "end_port" => "4040",
                  "firewall_id" => "3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a",
                  "id" => "d98af7f0-94c6-4a6e-995d-dec6cc6d4b88",
                  "label" => "test rule",
                  "openstack_security_group_rule_id" => nil,
                  "protocol" => "tcp",
                  "start_port" => "4000"
                }},
             request: %Civo.Request{
               body:
                 "{\"start_port\":4000,\"protocol\":\"tcp\",\"label\":\"test rule\",\"end_port\":4040,\"direction\":\"inbound\",\"cidr\":\"0.0.0.0/0\"}",
               method: :post,
               url: "https://api.civo.com/v2/firewalls/3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a/rules"
             },
             status: 200
           } = resp
  end

  test "delete firewall rule" do
    resp =
      use_cassette "delete firewall rule" do
        Firewalls.delete(
          "3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a",
          "d98af7f0-94c6-4a6e-995d-dec6cc6d4b88"
        )
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url:
                 "https://api.civo.com/v2/firewalls/3c9b41f0-4c14-4b40-b7d3-92ea5ec0b38a/rules/d98af7f0-94c6-4a6e-995d-dec6cc6d4b88"
             },
             status: 200
           } = resp
  end
end
