defmodule Civo.SnapshotSchedulesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{SnapshotSchedules, Response}

  test "schedule CRUD" do
    stubs = [
      [
        url: "~r/resourcesnapshotschedules/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"sch1"})
      ],
      [
        url: "~r/resourcesnapshotschedules/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"sch1"}])
      ],
      [
        url: "~r/resourcesnapshotschedules\/sch1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"sch1"})
      ],
      [
        url: "~r/resourcesnapshotschedules\/sch1/",
        method: "put",
        status_code: 200,
        body: ~s({"id":"sch1","name":"daily"})
      ],
      [
        url: "~r/resourcesnapshotschedules\/sch1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: %{"id" => "sch1"}} =
               SnapshotSchedules.create(%{name: "daily"}, "LON1")

      assert %Response{body: [%{"id" => "sch1"}]} = SnapshotSchedules.list("LON1")
      assert %Response{body: %{"id" => "sch1"}} = SnapshotSchedules.get("sch1", "LON1")

      assert %Response{body: %{"name" => "daily"}} =
               SnapshotSchedules.update("sch1", %{name: "daily"}, "LON1")

      assert %Response{body: %{"result" => "success"}} =
               SnapshotSchedules.delete("sch1", "LON1")
    end
  end
end
