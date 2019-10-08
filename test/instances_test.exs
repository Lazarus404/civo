defmodule Civo.InstancesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Instances, Request, Response}
  doctest Instances

  @id "6ed50817-e91c-40f3-aa4a-f6158ac8b3f5"
  @firewall_id "65233d15-cb74-460e-a372-71853bb6e263"

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/instances")
    :ok
  end

  test "list available sizes" do
    resp =
      use_cassette "list available sizes" do
        Instances.available_sizes()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "cpu_cores" => 1,
                    "description" => "Extra Small - 1GB RAM, 1 CPU Core, 25GB SSD Disk",
                    "disk_gb" => 25,
                    "id" => _,
                    "name" => "g2.xsmall",
                    "nice_name" => "Extra Small",
                    "ram_mb" => 1024,
                    "selectable" => true
                  },
                  %{
                    "cpu_cores" => 1,
                    "description" => "Small - 2GB RAM, 1 CPU Core, 25GB SSD Disk",
                    "disk_gb" => 25,
                    "id" => _,
                    "name" => "g2.small",
                    "nice_name" => "Small",
                    "ram_mb" => 2048,
                    "selectable" => true
                  },
                  %{
                    "cpu_cores" => 2,
                    "description" => "Medium - 4GB RAM, 2 CPU Cores, 50GB SSD Disk",
                    "disk_gb" => 50,
                    "id" => _,
                    "name" => "g2.medium",
                    "nice_name" => "Medium",
                    "ram_mb" => 4096,
                    "selectable" => true
                  },
                  %{
                    "cpu_cores" => 4,
                    "description" => "Large - 8GB RAM, 4 CPU Cores, 100GB SSD Disk",
                    "disk_gb" => 100,
                    "id" => _,
                    "name" => "g2.large",
                    "nice_name" => "Large",
                    "ram_mb" => 8192,
                    "selectable" => true
                  },
                  %{
                    "cpu_cores" => 6,
                    "description" => "Extra Large - 16GB RAM, 6 CPU Core, 150GB SSD Disk",
                    "disk_gb" => 150,
                    "id" => _,
                    "name" => "g2.xlarge",
                    "nice_name" => "Extra Large",
                    "ram_mb" => 16386,
                    "selectable" => true
                  },
                  %{
                    "cpu_cores" => 8,
                    "description" => "2X Large - 32GB RAM, 8 CPU Core, 200GB SSD Disk",
                    "disk_gb" => 200,
                    "id" => _,
                    "name" => "g2.2xlarge",
                    "nice_name" => "2X Large",
                    "ram_mb" => 32768,
                    "selectable" => true
                  }
                ]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/sizes"
             },
             status: 200
           } = resp
  end

  test "lists instances" do
    resp =
      use_cassette "list instances" do
        Instances.list()
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "items" => [
                    %{
                      "civostatsd_stats" => _,
                      "civostatsd_stats_per_hour" => _,
                      "civostatsd_stats_per_minute" => _,
                      "civostatsd_token" => _,
                      "created_at" => _,
                      "firewall_id" => _,
                      "hostname" => "example.domain.com",
                      "id" => _,
                      "initial_password" => _,
                      "initial_user" => "ubuntu",
                      "network_id" => _,
                      "notes" => _,
                      "openstack_image_id" => _,
                      "openstack_server_id" => _,
                      "private_ip" => _,
                      "pseudo_ip" => _,
                      "public_ip" => _,
                      "region" => _,
                      "rescue_password" => _,
                      "reverse_dns" => _,
                      "size" => _,
                      "snapshot_id" => _,
                      "ssh_key" => _,
                      "status" => "ACTIVE",
                      "tags" => [_ | _],
                      "template_id" => _,
                      "volume_backed" => _
                    }
                    | _
                  ],
                  "page" => 1,
                  "pages" => _,
                  "per_page" => 20
                }},
             request: %Request{
               body: "page=1&per_page=20&tags=",
               method: :get,
               url: "https://api.civo.com/v2/instances"
             },
             status: 200
           } = resp
  end

  test "create an instance" do
    data = %Instances{
      count: 1,
      hostname: "test.domain.com",
      reverse_dns: nil,
      size: "g2.xsmall",
      region: "lon1",
      public_ip: "none",
      network_id: nil,
      template_id: "811a8dfb-8202-49ad-b1ef-1e6320b20497",
      snapshot_id: nil,
      initial_user: "ubuntu",
      ssh_key_id: "5b391602-7d6d-49ad-aaf0-df5dcaa8e952",
      tags: ""
    }

    resp =
      use_cassette "create an instance" do
        Instances.create(data)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "civostatsd_stats" => nil,
                  "civostatsd_stats_per_hour" => [],
                  "civostatsd_stats_per_minute" => [],
                  "civostatsd_token" => _,
                  "created_at" => "2019-10-07T15:12:17.000+01:00",
                  "firewall_id" => "default",
                  "hostname" => "test.domain.com",
                  "id" => _,
                  "initial_password" => nil,
                  "initial_user" => "ubuntu",
                  "network_id" => _,
                  "notes" => nil,
                  "openstack_image_id" => nil,
                  "openstack_server_id" => nil,
                  "private_ip" => nil,
                  "pseudo_ip" => nil,
                  "public_ip" => nil,
                  "region" => "lon1",
                  "rescue_password" => nil,
                  "reverse_dns" => nil,
                  "size" => "g2.xsmall",
                  "snapshot_id" => nil,
                  "ssh_key" => _,
                  "status" => "BUILD_PENDING",
                  "tags" => [],
                  "template_id" => _,
                  "volume_backed" => nil
                }},
             request: %Civo.Request{
               body: _,
               method: :post,
               url: "https://api.civo.com/v2/instances"
             },
             status: 200
           } = resp
  end

  test "get an instance" do
    resp =
      use_cassette "get an instance" do
        Instances.get(@id)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "civostatsd_stats" => _,
                  "civostatsd_stats_per_hour" => _,
                  "civostatsd_stats_per_minute" => _,
                  "civostatsd_token" => _,
                  "created_at" => _,
                  "firewall_id" => "default",
                  "hostname" => "test.domain.com",
                  "id" => @id,
                  "initial_password" => _,
                  "initial_user" => "ubuntu",
                  "network_id" => _,
                  "notes" => nil,
                  "openstack_image_id" => _,
                  "openstack_server_id" => _,
                  "private_ip" => _,
                  "pseudo_ip" => _,
                  "public_ip" => nil,
                  "region" => "lon1",
                  "rescue_password" => nil,
                  "reverse_dns" => nil,
                  "size" => "g2.xsmall",
                  "snapshot_id" => nil,
                  "ssh_key" => _,
                  "status" => "ACTIVE",
                  "tags" => [],
                  "template_id" => _,
                  "volume_backed" => true
                }},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/instances/#{@id}"
             },
             status: 200
           } = resp
  end

  test "retag an instance" do
    resp =
      use_cassette "retag an instance" do
        Instances.retag(@id, "one two three")
      end

    assert %Response{body: {:ok, %{"result" => "success"}}} = resp
  end

  test "soft reboot an instance" do
    resp =
      use_cassette "soft reboot an instance" do
        Instances.soft_reboots(@id)
      end

    assert %Response{body: {:ok, %{"result" => "success"}}} = resp
  end

  test "hard reboot an instance" do
    resp =
      use_cassette "hard reboot an instance" do
        Instances.hard_reboots(@id)
      end

    assert %Response{body: {:ok, %{"result" => "success"}}} = resp
  end

  test "stop an instance" do
    resp =
      use_cassette "stop an instance" do
        Instances.stop(@id)
      end

    assert %Response{body: {:ok, %{"result" => "success"}}} = resp
  end

  test "start an instance" do
    resp =
      use_cassette "start an instance" do
        Instances.start(@id)
      end

    assert %Response{body: {:ok, %{"result" => "success"}}} = resp
  end

  test "resize an instance" do
    resp =
      use_cassette "resize an instance" do
        Instances.resize(@id, "g2.small")
      end

    assert %Response{body: {:ok, %{"result" => "success"}}} = resp
  end

  test "change firewall for an instance" do
    resp =
      use_cassette "change firewall for an instance" do
        Instances.firewall(@id, @firewall_id)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "civostatsd_stats" => _,
                  "civostatsd_stats_per_hour" => _,
                  "civostatsd_stats_per_minute" => _,
                  "civostatsd_token" => _,
                  "created_at" => _,
                  "firewall_id" => @firewall_id,
                  "hostname" => "test.domain.com",
                  "id" => _,
                  "initial_password" => _,
                  "initial_user" => "ubuntu",
                  "network_id" => _,
                  "notes" => _,
                  "openstack_image_id" => _,
                  "openstack_server_id" => _,
                  "private_ip" => _,
                  "pseudo_ip" => _,
                  "public_ip" => _,
                  "region" => "lon1",
                  "rescue_password" => _,
                  "reverse_dns" => _,
                  "size" => "g2.small",
                  "snapshot_id" => _,
                  "ssh_key" => _,
                  "status" => "SHUTOFF",
                  "tags" => _,
                  "template_id" => _,
                  "volume_backed" => _
                }},
             request: %Request{
               body: "{\"firewall_id\":\"#{@firewall_id}\"}",
               method: :put,
               url: "https://api.civo.com/v2/instances/#{@id}/firewall"
             },
             status: 200
           } = resp
  end

  test "move instance ip" do
    resp =
      use_cassette "move instance ip" do
        Instances.move_ip(@id, "185.136.232.157")
      end

    assert %Response{body: {:ok, %{"result" => "success"}}} = resp
  end
end
