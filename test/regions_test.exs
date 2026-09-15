defmodule Civo.RegionsTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{Regions, Response}

  test "list available regions" do
    use_cassette :stub,
      url: "~r/regions/",
      method: "get",
      status_code: 200,
      body: ~s([{"code":"lon1"}]) do
      assert %Response{body: [%{"code" => "lon1"}]} = Regions.available_regions()
    end
  end
end
