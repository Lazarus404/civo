defmodule Civo.KubernetesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{Kubernetes, Response}

  test "list and get clusters" do
    stubs = [
      [
        url: "~r/kubernetes\/clusters/",
        method: "get",
        status_code: 200,
        body: ~s({"page":1,"items":[{"id":"c1","name":"test"}]})
      ],
      [
        url: "~r/kubernetes\/clusters\/c1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"c1","name":"test"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: %{"items" => [%{"id" => "c1"}]}} = Kubernetes.list("LON1")
      assert %Response{body: %{"id" => "c1"}} = Kubernetes.get("c1", "LON1")
    end
  end

  test "create update recycle delete" do
    stubs = [
      [
        url: "~r/kubernetes\/clusters/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"c1","name":"test","status":"BUILDING"})
      ],
      [
        url: "~r/kubernetes\/clusters\/c1/",
        method: "put",
        status_code: 200,
        body: ~s({"id":"c1","name":"renamed"})
      ],
      [
        url: "~r/recycle/",
        method: "post",
        status_code: 200,
        body: ~s({"result":"success"})
      ],
      [
        url: "~r/kubernetes\/clusters\/c1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      data = %Kubernetes{
        name: "test",
        region: "LON1",
        network_id: "net-1",
        pools: [%{id: "p1", size: "g4s.kube.small", count: 1}]
      }

      assert %Response{body: %{"id" => "c1"}} = Kubernetes.create(data)

      assert %Response{body: %{"name" => "renamed"}} =
               Kubernetes.update(
                 "c1",
                 %{name: "renamed", pools: [%{id: "p1", size: "g4s.kube.small", count: 2}]},
                 "LON1"
               )

      assert %Response{body: %{"result" => "success"}} =
               Kubernetes.recycle("c1", "node-1", "LON1")

      assert %Response{body: %{"result" => "success"}} = Kubernetes.delete("c1", "LON1")
    end
  end

  test "applications and versions" do
    stubs = [
      [
        url: "~r/kubernetes\/applications/",
        method: "get",
        status_code: 200,
        body: ~s([{"name":"MariaDB"}])
      ],
      [
        url: "~r/kubernetes\/versions/",
        method: "get",
        status_code: 200,
        body: ~s([{"version":"1.28.0+k3s1","default":true}])
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: [%{"name" => "MariaDB"}]} = Kubernetes.applications()
      assert %Response{body: [%{"default" => true}]} = Kubernetes.versions()
    end
  end
end
