defmodule Civo.QuotaTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{Quota, Response}

  test "get quota" do
    use_cassette :stub,
      url: "~r/quota/",
      method: "get",
      status_code: 200,
      body: ~s({"instance_count_limit":32,"cpu_core_limit":16}) do
      assert %Response{body: %{"instance_count_limit" => 32}} = Quota.get()
    end
  end
end
