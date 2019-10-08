defmodule Civo.LoadBalancersTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{LoadBalancers, Request, Response}
  doctest LoadBalancers

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/load_balancers")
    :ok
  end

  test "lists load balancers" do
    resp =
      use_cassette "list load balancers" do
        LoadBalancers.list()
      end

    assert %Response{
             body: {:ok, _},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/loadbalancers"
             },
             status: 200
           } = resp
  end

  test "create a load balancer" do
    data = %LoadBalancers{
      hostname: "test.example.com",
      backends: [
        %{
          instance_id: "92608a9f-ad7b-47c4-ab54-3bbd3f8fe94b",
          port: 80,
          protocol: :http
        }
      ]
    }

    resp =
      use_cassette "create load balancer" do
        LoadBalancers.create(data)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "backends" => [
                    %{
                      "created_at" => _,
                      "deleted_at" => _,
                      "id" => "dabe2e9c-1640-4690-8bed-c08408c15cd4",
                      "instance_id" => "92608a9f-ad7b-47c4-ab54-3bbd3f8fe94b",
                      "load_balancer_id" => "6b922e4a-e148-4767-9ce8-09745d753640",
                      "port" => 80,
                      "protocol" => "http",
                      "updated_at" => _
                    }
                    | _
                  ],
                  "default_hostname" => false,
                  "fail_timeout" => 30,
                  "health_check_path" => "/",
                  "hostname" => "test.example.com",
                  "id" => "6b922e4a-e148-4767-9ce8-09745d753640",
                  "ignore_invalid_backend_tls" => true,
                  "max_conns" => 10,
                  "max_request_size" => 20,
                  "policy" => "random",
                  "port" => 80,
                  "protocol" => "http",
                  "tls_certificate" => _,
                  "tls_key" => _
                }},
             request: %Request{
               body:
                 "{\"tls_key\":null,\"tls_certificate\":null,\"protocol\":null,\"port\":\"80\",\"policy\":\"random\",\"max_request_size\":20,\"max_conns\":10,\"ignore_invalid_backend_tls\":true,\"hostname\":\"test.example.com\",\"health_check_path\":\"/\",\"fail_timeout\":30,\"backends\":[{\"protocol\":\"http\",\"port\":80,\"instance_id\":\"92608a9f-ad7b-47c4-ab54-3bbd3f8fe94b\"}]}",
               method: :post,
               url: "https://api.civo.com/v2/loadbalancers"
             },
             status: 200
           } = resp
  end

  test "update a load balancer" do
    data = %LoadBalancers{
      hostname: "test.example.co.uk",
      backends: [
        %{
          instance_id: "92608a9f-ad7b-47c4-ab54-3bbd3f8fe94b",
          port: 443,
          protocol: :https
        }
      ]
    }

    resp =
      use_cassette "update load balancer" do
        LoadBalancers.update("6b922e4a-e148-4767-9ce8-09745d753640", data)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "backends" => [
                    %{
                      "created_at" => _,
                      "deleted_at" => _,
                      "id" => "65750b89-2084-4da6-9ca9-887f1248770f",
                      "instance_id" => "92608a9f-ad7b-47c4-ab54-3bbd3f8fe94b",
                      "load_balancer_id" => "6b922e4a-e148-4767-9ce8-09745d753640",
                      "port" => 443,
                      "protocol" => "https",
                      "updated_at" => _
                    }
                    | _
                  ],
                  "default_hostname" => false,
                  "fail_timeout" => 30,
                  "health_check_path" => "/",
                  "hostname" => "test.example.co.uk",
                  "id" => "6b922e4a-e148-4767-9ce8-09745d753640",
                  "ignore_invalid_backend_tls" => true,
                  "max_conns" => 10,
                  "max_request_size" => 20,
                  "policy" => "random",
                  "port" => 80,
                  "protocol" => "http",
                  "tls_certificate" => _,
                  "tls_key" => _
                }},
             request: %Request{
               body:
                 "{\"tls_key\":null,\"tls_certificate\":null,\"protocol\":null,\"port\":\"80\",\"policy\":\"random\",\"max_request_size\":20,\"max_conns\":10,\"ignore_invalid_backend_tls\":true,\"hostname\":\"test.example.co.uk\",\"health_check_path\":\"/\",\"fail_timeout\":30,\"backends\":[{\"protocol\":\"https\",\"port\":443,\"instance_id\":\"92608a9f-ad7b-47c4-ab54-3bbd3f8fe94b\"}]}",
               method: :put,
               url: "https://api.civo.com/v2/loadbalancers/6b922e4a-e148-4767-9ce8-09745d753640"
             },
             status: 200
           } = resp
  end

  test "delete a load balancer" do
    resp =
      use_cassette "delete load balancer" do
        LoadBalancers.delete("6b922e4a-e148-4767-9ce8-09745d753640")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url: "https://api.civo.com/v2/loadbalancers/6b922e4a-e148-4767-9ce8-09745d753640"
             },
             status: 200
           } = resp
  end
end
