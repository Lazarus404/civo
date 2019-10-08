defmodule Civo.DNSTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{DNS, Request, Response}
  doctest DNS

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/dns")
    :ok
  end

  test "lists domains" do
    resp =
      use_cassette "list domains" do
        DNS.list_domains()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "account_id" => _,
                    "id" => _,
                    "name" => _
                  }
                  | _
                ]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/dns"
             },
             status: 200
           } = resp
  end

  test "create domain" do
    resp =
      use_cassette "create domain" do
        DNS.create_domain("test.co.uk")
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => "d7535033-315b-476f-b87e-86e7c075f11c",
                  "name" => "test.co.uk",
                  "result" => "success"
                }},
             request: %Request{
               body: "{\"name\":\"test.co.uk\"}",
               method: :post,
               url: "https://api.civo.com/v2/dns"
             },
             status: 200
           } = resp
  end

  test "update domain" do
    resp =
      use_cassette "update domain" do
        DNS.update_domain("54f151f9-c529-4cc2-9225-db30306d6234", "test.co.nz")
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => "54f151f9-c529-4cc2-9225-db30306d6234",
                  "name" => "test.co.nz",
                  "result" => "success"
                }},
             request: %Request{
               body: "{\"name\":\"test.co.nz\"}",
               method: :put,
               url: "https://api.civo.com/v2/dns/54f151f9-c529-4cc2-9225-db30306d6234"
             },
             status: 200
           } = resp
  end

  test "delete domain" do
    resp =
      use_cassette "delete domain" do
        DNS.delete_domain("54f151f9-c529-4cc2-9225-db30306d6234")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url: "https://api.civo.com/v2/dns/54f151f9-c529-4cc2-9225-db30306d6234"
             },
             status: 200
           } = resp
  end

  test "list dns" do
    resp =
      use_cassette "list dns" do
        DNS.list_dns("54f151f9-c529-4cc2-9225-db30306d6234")
      end

    assert %Response{
             body: {:ok, []},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/dns/54f151f9-c529-4cc2-9225-db30306d6234/records"
             },
             status: 200
           } = resp
  end

  test "create dns" do
    data = %DNS{
      type: "a",
      name: "www",
      value: "127.0.0.1",
      ttl: 3600
    }

    resp =
      use_cassette "create dns" do
        DNS.create_dns("54f151f9-c529-4cc2-9225-db30306d6234", data)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "account_id" => nil,
                  "created_at" => _,
                  "domain_id" => "54f151f9-c529-4cc2-9225-db30306d6234",
                  "id" => "01f06424-15de-4a42-b8ec-eff144f865d0",
                  "name" => "www",
                  "priority" => nil,
                  "ttl" => 3600,
                  "type" => "a",
                  "updated_at" => _,
                  "value" => "127.0.0.1"
                }},
             request: %Request{
               body:
                 "{\"value\":\"127.0.0.1\",\"type\":\"a\",\"ttl\":3600,\"priority\":null,\"name\":\"www\"}",
               method: :post,
               url: "https://api.civo.com/v2/dns/54f151f9-c529-4cc2-9225-db30306d6234/records"
             },
             status: 200
           } = resp
  end

  test "update dns" do
    data = %DNS{
      type: "a",
      name: "sub",
      value: "127.0.0.2",
      ttl: 3600
    }

    resp =
      use_cassette "update dns" do
        DNS.update_dns(
          "e0e3ca06-d5c4-4e6d-844c-5ad1993cd55f",
          "54f151f9-c529-4cc2-9225-db30306d6234",
          data
        )
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "account_id" => nil,
                  "created_at" => _,
                  "domain_id" => "54f151f9-c529-4cc2-9225-db30306d6234",
                  "id" => "e0e3ca06-d5c4-4e6d-844c-5ad1993cd55f",
                  "name" => "sub",
                  "priority" => nil,
                  "ttl" => 3600,
                  "type" => "a",
                  "updated_at" => _,
                  "value" => "127.0.0.2"
                }},
             request: %Request{
               body:
                 "{\"value\":\"127.0.0.2\",\"type\":\"a\",\"ttl\":3600,\"priority\":null,\"name\":\"sub\"}",
               method: :put,
               url:
                 "https://api.civo.com/v2/dns/54f151f9-c529-4cc2-9225-db30306d6234/records/e0e3ca06-d5c4-4e6d-844c-5ad1993cd55f"
             },
             status: 200
           } = resp
  end

  test "delete dns" do
    resp =
      use_cassette "delete dns" do
        DNS.delete_dns(
          "01f06424-15de-4a42-b8ec-eff144f865d0",
          "54f151f9-c529-4cc2-9225-db30306d6234"
        )
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url:
                 "https://api.civo.com/v2/dns/54f151f9-c529-4cc2-9225-db30306d6234/records/01f06424-15de-4a42-b8ec-eff144f865d0"
             },
             status: 200
           } = resp
  end
end
