defmodule Civo.SSHTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney, options: [clear_mock: true]
  alias Civo.{SSH, Request, Response}
  doctest SSH

  @id "5b391602-7d6d-49ad-aaf0-df5dcaa8e952"

  @body "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDmrBQ2a+bfVRlrL/kNbt0Qwi8gNDXJ5yQsEoLgTDatgBSTZSOjd6hKl4bTksUKoN1qYg2Vvn4xuK3cMBlX1HGDbDDaNn9jbJm4hhMb6EuRzUmbx9YFA+IIoDotFuG01p2MuZN7ZZFxfZQcb4ZWLjg9GP5zUcXIak9c3dCFSXvz5gTyO5aVZSJMgWnpZS0iQvR+sCG5gZ51+3g/bf4zF95jtWpsG0mnmoiFCdvGFom0EesvLesjnKoiiEC1XHKKYrhcZnWkkqmmvFL2n0Isn7MWG9fMze8DSF6MjopsqcegTxlAicmlr053qK7szkSK9tm66MqV4A3qCxaUyHjYY+mT test"

  setup do
    ExVCR.Config.cassette_library_dir("test/fixture/vcr_cassettes/ssh")
    :ok
  end

  test "lists SSH keys" do
    resp =
      use_cassette "list ssh keys" do
        SSH.list()
      end

    assert %Response{
             body:
               {:ok,
                [
                  %{
                    "fingerprint" => "",
                    "id" => "5b3bc502-7d6d-49ad-aaf0-df5dc4fa952",
                    "name" => "blade"
                  }
                ]},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/sshkeys"
             },
             status: 200
           } = resp
  end

  test "get SSH key" do
    resp =
      use_cassette "get ssh key" do
        SSH.get(@id)
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "fingerprint" => "",
                  "id" => "5b3bc502-7d6d-49ad-aaf0-df5dc4fa952",
                  "name" => "Blade"
                }},
             request: %Request{
               body: "",
               method: :get,
               url: "https://api.civo.com/v2/sshkeys/5b391602-7d6d-49ad-aaf0-df5dcaa8e952"
             },
             status: 200
           } = resp
  end

  test "upload SSH key" do
    resp =
      use_cassette "upload ssh key" do
        SSH.upload(%SSH{name: "test", public_key: @body})
      end

    assert %Response{
             body:
               {:ok,
                %{
                  "id" => _,
                  "result" => "success"
                }},
             request: %Request{
               body: "{\"public_key\":\"#{@body}\",\"name\":\"test\"}",
               method: :post,
               url: "https://api.civo.com/v2/sshkeys"
             },
             status: 200
           } = resp
  end

  test "delete SSH key" do
    resp =
      use_cassette "delete ssh key" do
        SSH.delete(@id)
      end

    assert %Response{
             body: {:ok, %{"result" => "success"}},
             request: %Request{
               body: nil,
               method: :delete,
               url: "https://api.civo.com/v2/sshkeys/#{@id}"
             },
             status: 200
           } = resp
  end
end
