defmodule Civo.TemplatesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Templates, Request, Response}
  doctest Templates

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/templates")
    :ok
  end

  test "lists templates" do
    resp =
      use_cassette "list templates" do
        Templates.list()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "account_id" => _,
                    "cloud_config" => _,
                    "code" => _,
                    "default_username" => _,
                    "description" => _,
                    "id" => _,
                    "image_id" => _,
                    "name" => _,
                    "short_description" => _,
                    "volume_id" => _
                  }
                  | _
                ]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/templates"
             },
             status: 200
           } = resp
  end

  test "create template" do
    resp =
      use_cassette "create template" do
        Templates.create(%Templates{
          code: "abc321",
          name: "test321",
          image_id: "7b4b616e-71f3-4419-9777-7aee66fad62c"
        })
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => "91ed6a26-5ad9-4cfc-ad81-17996c664ca5",
                  "result" => "success"
                }},
             request: %Request{
               body:
                 "{\"volume_id\":null,\"short_description\":null,\"name\":\"test321\",\"image_id\":\"7b4b616e-71f3-4419-9777-7aee66fad62c\",\"id\":null,\"description\":null,\"default_username\":null,\"code\":\"abc321\",\"cloud_config\":null}",
               method: :post,
               url: "https://api.civo.com/v2/templates"
             },
             status: 200
           } = resp
  end

  test "update template" do
    resp =
      use_cassette "update template" do
        Templates.update(%Templates{
          id: "91ed6a26-5ad9-4cfc-ad81-17996c664ca5",
          code: "abc4321",
          name: "test4321",
          image_id: "7b4b616e-71f3-4419-9777-7aee66fad62c"
        })
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => "265b12da-4427-425a-848e-9547b94cacfd",
                  "result" => "success"
                }},
             request: %Request{
               body:
                 "{\"volume_id\":null,\"short_description\":null,\"name\":\"test4321\",\"image_id\":\"7b4b616e-71f3-4419-9777-7aee66fad62c\",\"id\":\"91ed6a26-5ad9-4cfc-ad81-17996c664ca5\",\"description\":null,\"default_username\":null,\"code\":\"abc4321\",\"cloud_config\":null}",
               method: :post,
               url: "https://api.civo.com/v2/templates"
             },
             status: 200
           } = resp
  end

  test "delete template" do
    resp =
      use_cassette "delete template" do
        Templates.delete("91ed6a26-5ad9-4cfc-ad81-17996c664ca5")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url: "https://api.civo.com/v2/templates/91ed6a26-5ad9-4cfc-ad81-17996c664ca5"
             },
             status: 200
           } = resp
  end
end
