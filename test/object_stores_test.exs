defmodule Civo.ObjectStoresTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{ObjectStores, Response}

  test "object stores and credentials" do
    stubs = [
      [
        url: "~r/objectstores/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"os1","name":"bucket"})
      ],
      [
        url: "~r/objectstores/",
        method: "get",
        status_code: 200,
        body: ~s({"items":[{"id":"os1"}]})
      ],
      [
        url: "~r/objectstores\/os1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"os1"})
      ],
      [
        url: "~r/objectstores\/os1/",
        method: "patch",
        status_code: 200,
        body: ~s({"id":"os1","size":600})
      ],
      [
        url: "~r/objectstores\/os1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [
        url: "~r/objectstore\/credentials/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"cred1"})
      ],
      [
        url: "~r/objectstore\/credentials/",
        method: "get",
        status_code: 200,
        body: ~s({"items":[{"id":"cred1"}]})
      ],
      [
        url: "~r/objectstore\/credentials\/cred1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"cred1"})
      ],
      [
        url: "~r/objectstore\/credentials\/cred1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: %{"id" => "os1"}} =
               ObjectStores.create(%{name: "bucket", region: "LON1"})

      assert %Response{body: %{"items" => [%{"id" => "os1"}]}} =
               ObjectStores.list(%{region: "LON1"})

      assert %Response{body: %{"id" => "os1"}} = ObjectStores.get("os1", "LON1")
      assert %Response{body: %{"size" => 600}} = ObjectStores.update("os1", %{size: 600}, "LON1")
      assert %Response{body: %{"result" => "success"}} = ObjectStores.delete("os1", "LON1")

      assert %Response{body: %{"id" => "cred1"}} =
               ObjectStores.create_credential(%{name: "creds", region: "LON1"})

      assert %Response{body: %{"items" => [%{"id" => "cred1"}]}} =
               ObjectStores.list_credentials(%{region: "LON1"})

      assert %Response{body: %{"id" => "cred1"}} = ObjectStores.get_credential("cred1", "LON1")

      assert %Response{body: %{"result" => "success"}} =
               ObjectStores.delete_credential("cred1", "LON1")
    end
  end
end
