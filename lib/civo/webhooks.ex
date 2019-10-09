defmodule Civo.WebHooks do
  @moduledoc """
  Open certain actions taking place within your account, Civo can 
  trigger a JSON POST callback to a URL or your choice.

  Your Webhook handlers are expected to respond within 5 seconds. 
  If they take longer than this, then the failures count will be 
  incremented and the webhook queued for reprocessing. Reprocessing 
  happens at 5 minutes, 30 minutes, 1 hour, 2 hours, 6 hours - and 
  after that the webhook will be disabled.

  The headers of the request from our servers will contain the 
  following two important headers: X-Civo-Event and X-Civo-Signature. 
  X-Civo-Event is a UUID that is unique to this event. Civo don't track 
  them ourside, but retries of the same event will have the same ID, 
  so you can track it and not process it twice. X-Civo-Signature is an 
  OpenSSL HMAC SHA1 digest of the entire payload using the 
  secret of the webhook. The secret is randomly generated when the 
  webhook is created if one isn't specified. A simple example of how 
  to calculate this in Elixir would be:

  ```elixir
  signature =
    :crypto.hmac(:sha, webhook.secret, request.body)
    |> Base.encode16()
  ```

  The following events are available to subscribe to:

  | Name | Description |
  | ---- | ----------- |
  | `*` | any event happens |
  | `instance.created` | after the instance has been requested to be built from OpenStack's Nova |
  | `instance.active` | when the instance returns an `ACTIVE` status after `BUILDING` |
  | `instance.updated` | when the instance is renamed |
  | `instance.deleted` | when the instance has been requested to be deleted |
  | `instance.firewall.updated` | after OpenStack's Nova has been told to change the firewall for an instance |
  | `instance.rebooted` | after OpenStack's Nova returns an ACTIVE status for an instance after it had been REBOOTING |
  | `instance.rebuilt` | after OpenStack's Nova has been instructed to rebuild an instance (note: not when it's completed) |
  | `instance.stopped` | after OpenStack's Nova has been instructed to stop an instance (note: not when it's finished shutting down) |
  | `instance.started` | after OpenStack's Nova has been instructed to start an instance (note: not when it's completed booting up and all daemons running) |
  | `instance.restored` | after OpenStack's Nova has been instructed to restore an instance from a snapshot (note: not when it's completed) |
  | `instance.tags.updated` | when an instance's tags have changed |
  | `instance.resized` | after an instance has been resized |
  | `instance.ip_address.updated` | when a newly launched instance get's its public IP |
  | `instance.high_cpu.started` | when an instance's CPU goes above 80% |
  | `instance.high_cpu.ended` | when an instance's CPU drops back below 80% |
  | `instance.rescued` | after OpenStack's Nova has been instructed to rescue an instance (note: not when it's completed being rescued) |
  | `instance.unrescued` | after OpenStack's Nova has been instructed to revert an instance from a rescued state (note: not when it's completed reverting from a rescued state) |
  | `domain.created` | after a domain name has been added to our DNS service |
  | `domain.deleted` | after a domain has been removed from our DNS service |
  | `domain_record.created` | after a DNS record has been added for a domain in our DNS service |
  | `domain_record.updated` | after a DNS record has been changed for a domain in our DNS service |
  | `domain_record.deleted` | after a DNS record has been removed for a domain from our DNS service |
  | `firewall.created` | after OpenStack's Neutron has been instructed to create the firewall |
  | `firewall.updated` | after OpenStack's Neutron has been instructed to rename the firewall |
  | `firewall.deleted` | after OpenStack's Neutron has been instructed to remove the firewall |
  | `firewall_rule.created` | after OpenStack's Neutron has been instructed to add a rule to a firewall |
  | `firewall_rule.deleted` | after OpenStack's Neutron has been instructed to remove a rule from a firewall |
  | `kubernetes_cluster.created` | after a Kubernetes cluster is initially created active |
  | `kubernetes_cluster.active` | after a Kubernetes cluster becomes fully active |
  | `kubernetes_cluster.failed` | after a Kubernetes cluster fails to become active |
  | `kubernetes_cluster.scaled` | after the scale of a Kubernetes cluster has been changed |
  | `kubernetes_cluster.node_reaped` | after a Kubernetes node is removed |
  | `kubernetes_cluster.too_many_rebuilds` | if a Kubernetes cluster fails to become fully active and fails the rebuilding node process too many times |
  | `load_balancer.created` | after a URL has been added to our load balancer service |
  | `load_balancer.updated` | after the settings for a URL has been changed in our load balancer service |
  | `load_balancer.deleted` | after a URL has been removed from our load balancer service |
  | `network.created` | after a network is added to our database |
  | `network.updated` | after a network is renamed from our database |
  | `network.deleted` | after a network is removed from our database |
  | `ssh_key.created` | after an SSH key has been uploaded to our site |
  | `ssh_key.updated` | after an SSH key has been changed |
  | `ssh_key.deleted` | after an SSH key has been deleted |
  | `snapshot.created` | after a snapshot has been requested |
  | `snapshot.completed` | after a snapshot completes according to OpenStack's Glance service |
  | `snapshot.deleted` | after a snapshot has been removed |
  | `snapshot.failed` | after a snapshot fails to complete |
  | `snapshot.retrying` | after a snapshot fails to complete and is being queued to retry |
  | `template.created` | after a user template has been created |
  | `template.updated` | after a user template has been updated |
  | `template.deleted` | after a user template has been removed |
  | `volume.created` | after a volume has been created |
  | `volume.updated` | after a volume has been updated |
  | `volume.deleted` | after a volume has been removed |
  | `volume.attached` | after a volume has been attached |
  | `volume.detached` | after a volume has been detached |
  | `volume.resized` | after a volume has been resized |
  | `volume.renamed` | after a volume has been renamed |
  """
  #  This is a list of events that the webhook should be triggered for. Alternative you can use a list containing a single entry of "*" to signify trigger for all events. (required)
  defstruct events: nil,
            # This is the URL to send the webhook to (required).
            url: nil,
            #  This is if you want to specify your own secret, if not a random one will be created for you (optional).
            secret: nil

  @type t :: %{
          events: String.t(),
          url: String.t(),
          secret: String.t()
        }

  @path "webhooks"

  @doc """
  List all webhooks for an account.

  ### Request
  This request doesn't take any parameters.

  ### Response
  The response from the server will be a JSON array of webhooks.

  ```elixir
  [
    {
      "id": "b8de2e4e-72f4-4911-83ee-f4fc030fc4a2",
      "events": ["instance.created", "instance.deleted"],
      "url": "https://api.example.com/webhook",
      "secret": "DfeFUON8gorc5Zj0hk4GT1M9QImnRL6J",
      "disabled": false,
      "failures": 0,
      "last_failure_reason": "",
    },
    // ...
  ]
  ```
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Create a webhook for an account.

  Any user can create webhooks for their account.

  ### Request
  The required parameters are listed below.

  | Name | Description |
  | ---- | ----------- |
  | `events` | This is a list of events that the webhook should be triggered for. Alternative you can use a list containing a single entry of "*" to signify trigger for all events. (required) |
  | `url` | This is the URL to send the webhook to (required). |
  | `secret` | This is if you want to specify your own secret, if not a random one will be created for you (optional). |

  ### Response
  The response is a JSON representation of the webhook, including the secret.

  ```elixir
  {
    "id": "b8de2e4e-72f4-4911-83ee-f4fc030fc4a2",
    "events": ["*"],
    "url": "https://api.example.com/webhook",
    "secret": "DfeFUON8gorc5Zj0hk4GT1M9QImnRL6J",
    "disabled": false,
    "failures": 0,
    "last_failure_reason": "",
  }
  ```
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params),
    do: Civo.post(@path, params)

  @doc """
  Update a webhook.

  After creating a webhook, any user can update it.

  ### Request
  The update endpoint takes the ID of the webhook to update
  and the parameters of the webhook.

  ### Response
  The response is a JSON representation of the updated webhook, 
  including the secret.

  ```elixir
  {
    "id": "b8de2e4e-72f4-4911-83ee-f4fc030fc4a2",
    "events": ["*"],
    "url": "https://api.example.com/webhook",
    "secret": "DfeFUON8gorc5Zj0hk4GT1M9QImnRL6J",
    "disabled": false,
    "failures": 0,
    "last_failure_reason": "",
  }
  ```
  """
  @spec update(String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def update(id, %__MODULE__{} = params),
    do:
      Path.join([@path, id])
      |> Civo.put(@path, params)

  @doc """
  Test a webhook.

  Once a webhook is created, you can test it.

  ### Request
  The test endpoint takes the ID of the webhook to test.

  ### Response
  The response is a JSON object that simply confirms that the 
  request to test the webhook was received.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec test(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def test(id),
    do:
      Path.join([@path, id, "test"])
      |> Civo.post()

  @doc """
  Delete a webhook from an account.

  An account holder can remove one of their webhooks.

  ### Request
  This request takes the ID of the webhook 
  to delete. No confirmation step is required, 
  this step will remove the webhook immediately.

  ### Response
  The response from the server will be a JSON block. The response 
  will include a result field and the HTTP status will be 202 
  Accepted.

  ```elixir
  {
    "result": "success"
  }
  ```
  """
  @spec delete(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete(id),
    do:
      @path
      |> Path.join(id)
      |> Civo.delete()
end
