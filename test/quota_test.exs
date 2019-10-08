defmodule Civo.QuotaTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Quota, Request, Response}
  doctest Quota

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/quota")
    :ok
  end

  test "get quota" do
    resp =
      use_cassette "get quota" do
        Quota.get()
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "cpu_core_limit" => 32,
                  "cpu_core_usage" => 4,
                  "default_user_email_address" => _,
                  "default_user_id" => _,
                  "disk_gb_limit" => 800,
                  "disk_gb_usage" => 100,
                  "disk_snapshot_count_limit" => 48,
                  "disk_snapshot_count_usage" => 0,
                  "disk_volume_count_limit" => 64,
                  "disk_volume_count_usage" => 3,
                  "id" => _,
                  "instance_count_limit" => 32,
                  "instance_count_usage" => 3,
                  "network_count_limit" => 10,
                  "network_count_usage" => 2,
                  "port_count_limit" => 64,
                  "port_count_usage" => 4,
                  "public_ip_address_limit" => 32,
                  "public_ip_address_usage" => 3,
                  "ram_mb_limit" => 131_072,
                  "ram_mb_usage" => 6144,
                  "security_group_limit" => 16,
                  "security_group_rule_limit" => 160,
                  "security_group_rule_usage" => 14,
                  "security_group_usage" => 1,
                  "subnet_count_limit" => 10,
                  "subnet_count_usage" => 2
                }},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/quota"
             },
             status: 200
           } = resp
  end
end
