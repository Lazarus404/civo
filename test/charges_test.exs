defmodule Civo.ChargesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{Charges, Response}

  test "list charges" do
    use_cassette :stub,
      url: "~r/charges/",
      method: "get",
      status_code: 200,
      body: ~s([{"code":"instance-g3.small","num_hours":24}]) do
      assert %Response{body: [%{"num_hours" => 24}]} = Charges.list()
    end
  end
end
