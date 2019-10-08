defmodule Civo.NetworksTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Networks, Request, Response}
  doctest Networks

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/networks")
    :ok
  end

  test "lists networks" do
    resp =
      use_cassette "list networks" do
        Networks.list()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "cidr" => "10.0.0.0/8",
                    "default" => true,
                    "id" => _,
                    "label" => "Default",
                    "name" => "Default",
                    "region" => "lon1"
                  },
                  %{
                    "cidr" => "10.171.8.0/24",
                    "default" => false,
                    "id" => _,
                    "label" => "kube-network",
                    "name" => "kube-network",
                    "region" => nil
                  }
                ]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/networks"
             },
             status: 200
           } = resp
  end

  test "create network" do
    resp =
      use_cassette "create network" do
        Networks.create("test")
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => "fa702cf4-007b-4de2-bea8-306fe4ef6693",
                  "label" => "test",
                  "result" => "success"
                }},
             request: %Request{
               body: "{\"label\":\"test\"}",
               method: :post,
               url: "https://api.civo.com/v2/networks"
             },
             status: 200
           } = resp
  end

  test "rename a network" do
    resp =
      use_cassette "rename network" do
        Networks.rename("fa702cf4-007b-4de2-bea8-306fe4ef6693", "other")
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => "fa702cf4-007b-4de2-bea8-306fe4ef6693",
                  "label" => "other",
                  "result" => "success"
                }},
             request: %Request{
               body: "{\"label\":\"other\"}",
               method: :put,
               url: "https://api.civo.com/v2/networks/fa702cf4-007b-4de2-bea8-306fe4ef6693"
             },
             status: 200
           } = resp
  end

  test "delete a network" do
    resp =
      use_cassette "delete network" do
        Networks.delete("fa702cf4-007b-4de2-bea8-306fe4ef6693")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url: "https://api.civo.com/v2/networks/fa702cf4-007b-4de2-bea8-306fe4ef6693"
             },
             status: 200
           } = resp
  end
end
