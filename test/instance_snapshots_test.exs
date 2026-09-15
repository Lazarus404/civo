defmodule Civo.InstanceSnapshotsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{InstanceSnapshots, Response}

  test "instance snapshot lifecycle" do
    stubs = [
      [
        url: "~r/snapshots/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"s1","name":"snap"})
      ],
      [
        url: "~r/snapshots/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"s1","name":"snap"}])
      ],
      [
        url: "~r/snapshots\/s1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"s1","name":"snap"})
      ],
      [
        url: "~r/snapshots\/s1/",
        method: "put",
        status_code: 200,
        body: ~s({"id":"s1","name":"snap2"})
      ],
      [
        url: "~r/restore/",
        method: "post",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [
        url: "~r/snapshots\/s1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: %{"id" => "s1"}} =
               InstanceSnapshots.create("i1", %{name: "snap"}, "LON1")

      assert %Response{body: [%{"id" => "s1"}]} = InstanceSnapshots.list("i1", "LON1")
      assert %Response{body: %{"id" => "s1"}} = InstanceSnapshots.get("i1", "s1", "LON1")

      assert %Response{body: %{"name" => "snap2"}} =
               InstanceSnapshots.update("i1", "s1", %{name: "snap2"}, "LON1")

      assert %Response{body: %{"result" => "success"}} =
               InstanceSnapshots.restore("i1", "s1", "LON1")

      assert %Response{body: %{"result" => "success"}} =
               InstanceSnapshots.delete("i1", "s1", "LON1")
    end
  end
end
