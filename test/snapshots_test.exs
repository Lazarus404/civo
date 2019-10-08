defmodule Civo.SnapshotsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Snapshots, Request, Response}
  doctest Snapshots

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/snapshots")
    :ok
  end

  test "list available snapshots" do
    resp =
      use_cassette "list snapshots" do
        Snapshots.list()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "completed_at" => _,
                    "cron_timing" => nil,
                    "hostname" => _,
                    "id" => _,
                    "instance_id" => _,
                    "name" => "test",
                    "openstack_snapshot_id" => _,
                    "region" => "lon1",
                    "requested_at" => _,
                    "safe" => 0,
                    "size_gb" => 50,
                    "state" => "complete",
                    "template_id" => _
                  }
                ]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/snapshots"
             },
             status: 200
           } = resp
  end

  test "create a snapshot" do
    data = %Snapshots{
      instance_id: "6ed50817-e91c-40f3-aa4a-f6158ac8b3f5",
      safe: nil,
      cron_timing: nil
    }

    resp =
      use_cassette "create snapshot" do
        Snapshots.create("tmp_snapshot", data)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "completed_at" => nil,
                  "cron_timing" => nil,
                  "hostname" => "test.domain.com",
                  "id" => "bfe01092-c1eb-443b-ab6c-8a860c218288",
                  "instance_id" => _,
                  "name" => "tmp_snapshot",
                  "openstack_snapshot_id" => nil,
                  "region" => "lon1",
                  "requested_at" => nil,
                  "safe" => 0,
                  "size_gb" => nil,
                  "state" => "new",
                  "template_id" => _
                }},
             request: %Request{
               body:
                 "{\"safe\":null,\"instance_id\":\"6ed50817-e91c-40f3-aa4a-f6158ac8b3f5\",\"cron_timing\":null}",
               method: :put,
               url: "https://api.civo.com/v2/snapshots/tmp_snapshot"
             },
             status: 200
           } = resp
  end

  test "delete a snapshot" do
    tid = "bfe01092-c1eb-443b-ab6c-8a860c218288"

    resp =
      use_cassette "delete snapshot" do
        Snapshots.delete(tid)
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url: "https://api.civo.com/v2/snapshots/bfe01092-c1eb-443b-ab6c-8a860c218288"
             },
             status: 200
           } = resp
  end
end
