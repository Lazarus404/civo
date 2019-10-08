defmodule Civo.KubernetesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{Kubernetes, Request, Response}
  doctest Kubernetes

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/kubernetes")
    :ok
  end

  test "list clusters" do
    resp =
      use_cassette "list kubernetes" do
        Kubernetes.list()
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "items" => [
                    %{
                      "api_endpoint" => _,
                      "built_at" => _,
                      "created_at" => _,
                      "dns_entry" => _,
                      "id" => "be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa",
                      "installed_applications" => [
                        %{
                          "application" => "Traefik",
                          "category" => "architecture",
                          "configuration" => %{},
                          "dependencies" => nil,
                          "description" =>
                            "A reverse proxy/load-balancer that's easy, dynamic, automatic, fast, full-featured, open source, production proven and provides metrics.",
                          "image_url" => "https://api.civo.com/k3s-marketplace/traefik.png",
                          "installed" => true,
                          "maintainer" => "@Rancher_Labs",
                          "plan" => nil,
                          "post_install" =>
                            "## Traefik - Default ingress controller\n\n### External access to your services\n\nTraefik is installed in K3s as the default ingress controller. To use it for your applications all you have to do is apply a YAML file like the one below to handle ingress:\n\n```\napiVersion: extensions/v1beta1\nkind: Ingress\nmetadata:\n  name: yourapp-ingress\n  namespace: default\n  annotations:\n    kubernetes.io/ingress.class: traefik\nspec:\n  rules:\n  - host: www.example.com\n    http:\n      paths:\n      - path: /\n        backend:\n          serviceName: yourapp-service\n          servicePort: http\n```\n\nThis will open up http://www.example.com (assuming you pointed that non-real domain record to your cluster's IPs) to the whole world.\n",
                          "title" => nil,
                          "updated_at" => _,
                          "url" => "https://traefik.io",
                          "version" => "(default)"
                        }
                      ],
                      "instances" => [
                        %{
                          "created_at" => _,
                          "firewall_id" => _,
                          "hostname" => _,
                          "public_ip" => _,
                          "region" => "lon1",
                          "size" => "g2.xsmall",
                          "status" => "ACTIVE",
                          "tags" => ["civo-kubernetes:master"]
                        }
                        | _
                      ],
                      "kubeconfig" => nil,
                      "kubernetes_version" => _,
                      "name" => "test",
                      "num_target_nodes" => 3,
                      "ready" => false,
                      "status" => "INSTALLING",
                      "tags" => [],
                      "target_nodes_size" => "g2.xsmall",
                      "version" => "2"
                    }
                  ],
                  "page" => 1,
                  "pages" => 1,
                  "per_page" => 20
                }},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/kubernetes/clusters"
             },
             status: 200
           } = resp
  end

  test "create cluster" do
    data = %Kubernetes{
      name: "test",
      num_target_nodes: 3,
      target_nodes_size: "g2.xsmall",
      tags: ""
    }

    resp =
      use_cassette "create cluster" do
        Kubernetes.create(data)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "api_endpoint" => nil,
                  "built_at" => nil,
                  "created_at" => _,
                  "dns_entry" => _,
                  "id" => "be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa",
                  "installed_applications" => [
                    %{
                      "application" => "Traefik",
                      "category" => "architecture",
                      "configuration" => %{},
                      "dependencies" => nil,
                      "description" =>
                        "A reverse proxy/load-balancer that's easy, dynamic, automatic, fast, full-featured, open source, production proven and provides metrics.",
                      "image_url" => "https://api.civo.com/k3s-marketplace/traefik.png",
                      "installed" => true,
                      "maintainer" => "@Rancher_Labs",
                      "plan" => nil,
                      "post_install" =>
                        "## Traefik - Default ingress controller\n\n### External access to your services\n\nTraefik is installed in K3s as the default ingress controller. To use it for your applications all you have to do is apply a YAML file like the one below to handle ingress:\n\n```\napiVersion: extensions/v1beta1\nkind: Ingress\nmetadata:\n  name: yourapp-ingress\n  namespace: default\n  annotations:\n    kubernetes.io/ingress.class: traefik\nspec:\n  rules:\n  - host: www.example.com\n    http:\n      paths:\n      - path: /\n        backend:\n          serviceName: yourapp-service\n          servicePort: http\n```\n\nThis will open up http://www.example.com (assuming you pointed that non-real domain record to your cluster's IPs) to the whole world.\n",
                      "title" => nil,
                      "updated_at" => _,
                      "url" => "https://traefik.io",
                      "version" => "(default)"
                    }
                  ],
                  "instances" => _,
                  "kubeconfig" => _,
                  "kubernetes_version" => _,
                  "name" => "test",
                  "num_target_nodes" => 3,
                  "ready" => false,
                  "status" => "NEW",
                  "tags" => [],
                  "target_nodes_size" => "g2.xsmall",
                  "version" => "2"
                }},
             request: %Request{
               body:
                 "{\"target_nodes_size\":\"g2.xsmall\",\"tags\":\"\",\"num_target_nodes\":3,\"name\":\"test\",\"kubernetes_version\":null}",
               method: :post,
               url: "https://api.civo.com/v2/kubernetes/clusters"
             },
             status: 200
           } = resp
  end

  test "get cluster" do
    resp =
      use_cassette "get cluster" do
        Kubernetes.get("be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa")
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "api_endpoint" => _,
                  "built_at" => _,
                  "created_at" => _,
                  "dns_entry" => _,
                  "id" => "be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa",
                  "installed_applications" => [
                    %{
                      "application" => "Traefik",
                      "category" => "architecture",
                      "configuration" => %{},
                      "dependencies" => nil,
                      "description" =>
                        "A reverse proxy/load-balancer that's easy, dynamic, automatic, fast, full-featured, open source, production proven and provides metrics.",
                      "image_url" => "https://api.civo.com/k3s-marketplace/traefik.png",
                      "installed" => true,
                      "maintainer" => "@Rancher_Labs",
                      "plan" => nil,
                      "post_install" =>
                        "## Traefik - Default ingress controller\n\n### External access to your services\n\nTraefik is installed in K3s as the default ingress controller. To use it for your applications all you have to do is apply a YAML file like the one below to handle ingress:\n\n```\napiVersion: extensions/v1beta1\nkind: Ingress\nmetadata:\n  name: yourapp-ingress\n  namespace: default\n  annotations:\n    kubernetes.io/ingress.class: traefik\nspec:\n  rules:\n  - host: www.example.com\n    http:\n      paths:\n      - path: /\n        backend:\n          serviceName: yourapp-service\n          servicePort: http\n```\n\nThis will open up http://www.example.com (assuming you pointed that non-real domain record to your cluster's IPs) to the whole world.\n",
                      "title" => nil,
                      "updated_at" => _,
                      "url" => "https://traefik.io",
                      "version" => "(default)"
                    }
                  ],
                  "instances" => [
                    %{
                      "created_at" => _,
                      "firewall_id" => _,
                      "hostname" => _,
                      "public_ip" => _,
                      "region" => "lon1",
                      "size" => "g2.xsmall",
                      "status" => "ACTIVE",
                      "tags" => ["civo-kubernetes:installed", "civo-kubernetes:master"]
                    }
                    | _
                  ],
                  "kubeconfig" => _,
                  "kubernetes_version" => _,
                  "name" => "test",
                  "num_target_nodes" => 3,
                  "ready" => true,
                  "status" => "ACTIVE",
                  "tags" => [],
                  "target_nodes_size" => "g2.xsmall",
                  "version" => "2"
                }},
             request: %Request{
               body: "",
               method: :get,
               url:
                 "https://api.civo.com/v2/kubernetes/clusters/be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa"
             },
             status: 200
           } = resp
  end

  test "update cluster" do
    resp =
      use_cassette "update cluster" do
        Kubernetes.update("be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa", "delete_me", 2)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "api_endpoint" => _,
                  "built_at" => _,
                  "created_at" => _,
                  "dns_entry" => _,
                  "id" => "be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa",
                  "installed_applications" => [_ | _],
                  "instances" => [
                    %{
                      "created_at" => _,
                      "firewall_id" => _,
                      "hostname" => _,
                      "public_ip" => _,
                      "region" => "lon1",
                      "size" => "g2.xsmall",
                      "status" => "ACTIVE",
                      "tags" => ["civo-kubernetes:installed", "civo-kubernetes:master"]
                    }
                    | _
                  ],
                  "kubeconfig" => _,
                  "kubernetes_version" => _,
                  "name" => "delete_me",
                  "num_target_nodes" => 2,
                  "ready" => true,
                  "status" => "SCALING",
                  "tags" => [],
                  "target_nodes_size" => "g2.xsmall",
                  "version" => "2"
                }},
             request: %Request{
               body: "{\"num_target_nodes\":2,\"name\":\"delete_me\",\"applications\":\"\"}",
               method: :put,
               url:
                 "https://api.civo.com/v2/kubernetes/clusters/be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa"
             },
             status: 200
           } = resp
  end

  test "get applications" do
    resp =
      use_cassette "get applications" do
        Kubernetes.applications()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "category" => _,
                    "default" => _,
                    "dependencies" => _,
                    "description" => _,
                    "image_url" => _,
                    "maintainer" => _,
                    "name" => _,
                    "plans" => _,
                    "post_install" => _,
                    "title" => _,
                    "url" => _,
                    "version" => _
                  }
                  | _
                ]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/kubernetes/applications"
             },
             status: 200
           } = resp
  end

  test "recycle node" do
    resp =
      use_cassette "recycle node" do
        Kubernetes.recycle("be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa", "kube-node-707a")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: "{\"hostname\":\"kube-node-707a\"}",
               method: :post,
               url:
                 "https://api.civo.com/v2/kubernetes/clusters/be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa/recycle"
             },
             status: 200
           } = resp
  end

  test "delete cluster" do
    resp =
      use_cassette "delete cluster" do
        Kubernetes.delete("be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa")
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url:
                 "https://api.civo.com/v2/kubernetes/clusters/be80b74c-f6ee-4a4e-ab6c-fc0ce2885daa"
             },
             status: 200
           } = resp
  end
end
