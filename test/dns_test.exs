defmodule Civo.DNSTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{DNS, Response}

  test "domains and records" do
    stubs = [
      [
        url: "~r/v2\/dns/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"d1","name":"ex.com"}])
      ],
      [
        url: "~r/v2\/dns/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"d1","name":"ex.com","result":"success"})
      ],
      [
        url: "~r/v2\/dns\/d1/",
        method: "put",
        status_code: 200,
        body: ~s({"id":"d1","name":"other.com"})
      ],
      [
        url: "~r/records/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"r1","type":"a"}])
      ],
      [
        url: "~r/records/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"r1","type":"a"})
      ],
      [
        url: "~r/records\/r1/",
        method: "put",
        status_code: 200,
        body: ~s({"id":"r1","value":"1.2.3.5"})
      ],
      [
        url: "~r/records\/r1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [
        url: "~r/v2\/dns\/d1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: [%{"id" => "d1"}]} = DNS.list_domains()
      assert %Response{body: %{"result" => "success"}} = DNS.create_domain("ex.com")
      assert %Response{body: %{"name" => "other.com"}} = DNS.update_domain("d1", "other.com")
      assert %Response{body: [%{"id" => "r1"}]} = DNS.list_dns("d1")

      assert %Response{body: %{"id" => "r1"}} =
               DNS.create_dns("d1", %DNS{type: "a", name: "www", value: "1.2.3.4"})

      assert %Response{body: %{"value" => "1.2.3.5"}} =
               DNS.update_dns("d1", "r1", %DNS{type: "a", name: "www", value: "1.2.3.5"})

      assert %Response{body: %{"result" => "success"}} = DNS.delete_dns("d1", "r1")
      assert %Response{body: %{"result" => "success"}} = DNS.delete_domain("d1")
    end
  end
end
