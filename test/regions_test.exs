defmodule Civo.RegionsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Regions, Request, Response}
  doctest Regions

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/regions")
    :ok
  end

  test "list available regions" do
    resp =
      use_cassette "list available regions" do
        Regions.available_regions()
      end

    assert %Response{
             body: {:ok, [%{"code" => "lon1"}]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/regions"
             },
             status: 200
           } = resp
  end
end
