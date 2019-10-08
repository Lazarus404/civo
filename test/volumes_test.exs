defmodule Civo.VolumesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Volumes, Request, Response}
  doctest Volumes

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/volumes")
    :ok
  end

  test "lists volumes" do
    resp =
      use_cassette "list volumes" do
        Volumes.list()
      end

    assert %Response{
             body: {:ok, []},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/volumes"
             },
             status: 200
           } = resp
  end

  test "create a volume" do
    data = %Volumes{
      name: "test",
      size_gb: 1,
      bootable: false
    }

    resp =
      use_cassette "create volume" do
        Volumes.create(data)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => "fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393",
                  "name" => "test",
                  "result" => "success"
                }},
             request: %Request{
               body: "{\"size_gb\":1,\"name\":\"test\",\"bootable\":false}",
               method: :post,
               url: "https://api.civo.com/v2/volumes"
             },
             status: 200
           } = resp
  end

  test "resize a volume" do
    resp =
      use_cassette "resize volume" do
        Volumes.resize("fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393", 2)
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: "{\"size_gb\":2}",
               method: :put,
               url: "https://api.civo.com/v2/volumes/fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393/resize"
             },
             status: 200
           } = resp
  end

  test "attach a volume" do
    resp =
      use_cassette "attach volume" do
        Volumes.attach(
          "fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393",
          "92608a9f-ad7b-47c4-ab54-3bbd3f8fe94b"
        )
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: "{\"instance_id\":\"92608a9f-ad7b-47c4-ab54-3bbd3f8fe94b\"}",
               method: :put,
               url: "https://api.civo.com/v2/volumes/fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393/attach"
             },
             status: 200
           } = resp
  end

  test "detach a volume" do
    resp =
      use_cassette "detach volume" do
        Volumes.detach("fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: "{}",
               method: :put,
               url: "https://api.civo.com/v2/volumes/fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393/detach"
             },
             status: 200
           } = resp
  end

  test "delete a volume" do
    resp =
      use_cassette "delete volume" do
        Volumes.delete("fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url: "https://api.civo.com/v2/volumes/fcf2ef52-34f4-4ef9-a3d7-daecb9f5f393"
             },
             status: 200
           } = resp
  end
end
