defmodule Civo.SSHTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Civo.{SSH, Response}

  test "ssh key CRUD" do
    stubs = [
      [
        url: "~r/sshkeys/",
        method: "get",
        status_code: 200,
        body: ~s([{"id":"k1","name":"default"}])
      ],
      [
        url: "~r/sshkeys\/k1/",
        method: "get",
        status_code: 200,
        body: ~s({"id":"k1","name":"default"})
      ],
      [
        url: "~r/sshkeys/",
        method: "post",
        status_code: 200,
        body: ~s({"id":"k1","result":"success"})
      ],
      [
        url: "~r/sshkeys\/k1/",
        method: "delete",
        status_code: 200,
        body: ~s({"result":"success"})
      ]
    ]

    use_cassette :stub, stubs do
      assert %Response{body: [%{"id" => "k1"}]} = SSH.list()
      assert %Response{body: %{"id" => "k1"}} = SSH.get("k1")

      assert %Response{body: %{"result" => "success"}} =
               SSH.create(%SSH{name: "default", public_key: "ssh-rsa AAA..."})

      assert %Response{body: %{"result" => "success"}} = SSH.delete("k1")
    end
  end
end
