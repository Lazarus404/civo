defmodule Civo.ChargesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Charges, Request, Response}
  doctest Charges

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/charges")
    :ok
  end

  test "list charges" do
    resp =
      use_cassette "list charges" do
        Charges.list()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "code" => _,
                    "from" => _,
                    "label" => _,
                    "num_hours" => _,
                    "product_id" => _,
                    "size_gb" => _,
                    "to" => _
                  }
                  | _
                ]},
             request: %Request{
               body: "from=&to=",
               method: :get,
               url: "https://api.civo.com/v2/charges"
             },
             status: 200
           } = resp
  end
end
