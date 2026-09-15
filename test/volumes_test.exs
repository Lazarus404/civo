defmodule Civo.VolumesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{Volumes, Response}

  test "volume CRUD and attach" do
    stubs = [
      [
        url: "~r/volumes/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"v1","name":"disk"}])
      ],
      [
        url: "~r/volumes/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"v1","name":"disk","result":"success"})
      ],
      [url: "~r/attach/", method: "put", status_code: 200, body: ~s({"result":"success"})],
      [url: "~r/detach/", method: "put", status_code: 200, body: ~s({"result":"success"})],
      [
        url: "~r/volumes\/v1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: [%{"id" => "v1"}]} = Volumes.list("LON1")

      assert %Response{body: %{"id" => "v1"}} =
               Volumes.create(%Volumes{
                 name: "disk",
                 size_gb: 25,
                 network_id: "net-1",
                 region: "LON1"
               })

      assert %Response{body: %{"result" => "success"}} = Volumes.attach("v1", "i1", "LON1")
      assert %Response{body: %{"result" => "success"}} = Volumes.detach("v1", "LON1")
      assert %Response{body: %{"result" => "success"}} = Volumes.delete("v1", "LON1")
    end
  end
end
