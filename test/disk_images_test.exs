defmodule Civo.DiskImagesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{DiskImages, Response}

  test "list get create delete" do
    stubs = [
      [
        url: "~r/disk_images/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"img1","name":"ubuntu"}])
      ],
      [
        url: "~r/disk_images\/img1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"img1","name":"ubuntu"})
      ],
      [
        url: "~r/disk_images/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"img2","status":"pending"})
      ],
      [
        url: "~r/disk_images\/img2/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: [%{"id" => "img1"}]} = DiskImages.list(%{region: "LON1"})
      assert %Response{body: %{"id" => "img1"}} = DiskImages.get("img1", "LON1")

      assert %Response{body: %{"id" => "img2"}} =
               DiskImages.create(%DiskImages{
                 name: "custom",
                 distribution: "ubuntu",
                 version: "22.04",
                 region: "LON1",
                 image_sha256: "abc",
                 image_md5: "def",
                 image_size: 1000
               })

      assert %Response{body: %{"result" => "success"}} = DiskImages.delete("img2", "LON1")
    end
  end
end
