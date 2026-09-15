defmodule CivoTest do
  use ExUnit.Case, async: false

  test "url joins v2 base path" do
    assert Civo.url("networks") == "https://api.civo.com/v2/networks"
  end

  test "region_params merges explicit region" do
    assert Civo.region_params("LON1", %{name: "x"}) == %{name: "x", region: "LON1"}
  end

  test "region_params keeps existing region key" do
    assert Civo.region_params("NYC1", %{region: "LON1"}) == %{region: "LON1"}
  end

  test "region_params uses config default when set" do
    Application.put_env(:civo, :region, "FRA1")

    try do
      assert Civo.region_params(nil, %{}) == %{region: "FRA1"}
    after
      Application.put_env(:civo, :region, nil)
    end
  end

  test "require_token! raises when unset" do
    prev = Application.get_env(:civo, :api_token)
    Application.put_env(:civo, :api_token, nil)

    try do
      assert_raise ArgumentError, ~r/api_token/, fn -> Civo.require_token!() end
    after
      Application.put_env(:civo, :api_token, prev)
    end
  end

  test "split_region keeps region in body and query" do
    assert {%{name: "x", region: "LON1"}, %{region: "LON1"}} =
             Civo.split_region(%{name: "x", region: "LON1"})

    assert {%{name: "x"}, %{}} = Civo.split_region(%{name: "x"})
  end

  test "require! raises on missing key" do
    assert_raise ArgumentError, ~r/hostname/, fn ->
      Civo.require!(%{size: "g3.small"}, [:hostname, :size])
    end
  end

  test "require! accepts map with all keys" do
    assert %{hostname: "h", size: "s"} =
             Civo.require!(%{hostname: "h", size: "s"}, [:hostname, :size])
  end

  test "require_region! uses config" do
    Application.put_env(:civo, :region, "LON1")

    try do
      assert "LON1" = Civo.require_region!(nil)
    after
      Application.put_env(:civo, :region, nil)
    end
  end

  test "require_region! raises when missing" do
    Application.put_env(:civo, :region, nil)

    assert_raise ArgumentError, ~r/region/, fn ->
      Civo.require_region!(nil)
    end
  end
end
