defmodule Civo.WebHooks do
  @moduledoc """
  Account webhooks (`/v2/webhooks`).

  Civo POSTs a JSON callback to your URL when subscribed events occur.
  Handlers should respond within 5 seconds; failures are retried at
  5m / 30m / 1h / 2h / 6h, then the webhook is disabled.

  Request headers include:

  * `X-Civo-Event` — UUID unique to the event (stable across retries)
  * `X-Civo-Signature` — HMAC-SHA1 of the body with the webhook secret

  Example signature check:

      signature =
        :crypto.mac(:hmac, :sha, webhook.secret, request_body)
        |> Base.encode16()

  ## Create fields (`t`)

  | Field | Required | Description |
  | --- | --- | --- |
  | `:events` | yes | List of event names, or `["*"]` for all |
  | `:url` | yes | Callback URL |
  | `:secret` | no | HMAC secret; random if omitted |

  ## Subscribable events

  | Name | Description |
  | ---- | ----------- |
  | `*` | any event |
  | `instance.created` | instance build requested |
  | `instance.active` | instance becomes ACTIVE |
  | `instance.updated` | instance renamed |
  | `instance.deleted` | instance delete requested |
  | `instance.firewall.updated` | firewall assignment changed |
  | `instance.rebooted` | reboot completed (ACTIVE) |
  | `instance.rebuilt` | rebuild instructed |
  | `instance.stopped` | stop instructed |
  | `instance.started` | start instructed |
  | `instance.restored` | restore from snapshot instructed |
  | `instance.tags.updated` | tags changed |
  | `instance.resized` | resize completed |
  | `instance.ip_address.updated` | public IP assigned |
  | `instance.high_cpu.started` | CPU above 80% |
  | `instance.high_cpu.ended` | CPU below 80% again |
  | `instance.rescued` | rescue instructed |
  | `instance.unrescued` | unrescue instructed |
  | `domain.created` | DNS domain added |
  | `domain.deleted` | DNS domain removed |
  | `domain_record.created` | DNS record added |
  | `domain_record.updated` | DNS record changed |
  | `domain_record.deleted` | DNS record removed |
  | `firewall.created` | firewall created |
  | `firewall.updated` | firewall renamed |
  | `firewall.deleted` | firewall removed |
  | `firewall_rule.created` | rule added |
  | `firewall_rule.deleted` | rule removed |
  | `kubernetes_cluster.created` | cluster created |
  | `kubernetes_cluster.active` | cluster fully active |
  | `kubernetes_cluster.failed` | cluster failed |
  | `kubernetes_cluster.scaled` | cluster scale changed |
  | `kubernetes_cluster.node_reaped` | node removed |
  | `kubernetes_cluster.too_many_rebuilds` | rebuild loop exhausted |
  | `load_balancer.created` | load balancer created |
  | `load_balancer.updated` | load balancer updated |
  | `load_balancer.deleted` | load balancer deleted |
  | `network.created` | network created |
  | `network.updated` | network renamed |
  | `network.deleted` | network deleted |
  | `ssh_key.created` | SSH key uploaded |
  | `ssh_key.updated` | SSH key updated |
  | `ssh_key.deleted` | SSH key deleted |
  | `snapshot.created` | snapshot requested |
  | `snapshot.completed` | snapshot completed |
  | `snapshot.deleted` | snapshot deleted |
  | `snapshot.failed` | snapshot failed |
  | `snapshot.retrying` | snapshot retrying |
  | `template.created` | (legacy) template created |
  | `template.updated` | (legacy) template updated |
  | `template.deleted` | (legacy) template deleted |
  | `volume.created` | volume created |
  | `volume.updated` | volume updated |
  | `volume.deleted` | volume deleted |
  | `volume.attached` | volume attached |
  | `volume.detached` | volume detached |
  | `volume.resized` | volume resized |
  | `volume.renamed` | volume renamed |
  """

  @typedoc "Parameters for creating or updating a webhook."
  @type t :: %__MODULE__{
          events: [String.t()] | nil,
          url: String.t() | nil,
          secret: String.t() | nil
        }

  defstruct events: nil,
            url: nil,
            secret: nil

  @path "webhooks"

  @doc """
  Lists webhooks for the account (`GET /v2/webhooks`).
  """
  @spec list() :: Civo.Response.t() | Civo.Error.t()
  def list(),
    do: Civo.get(@path)

  @doc """
  Creates a webhook (`POST /v2/webhooks`).

  See the module documentation for fields on `t` and available events.
  """
  @spec create(t()) :: Civo.Response.t() | Civo.Error.t()
  def create(%__MODULE__{} = params) do
    params
    |> Civo.require!([:events, :url])
    |> then(&Civo.post(@path, &1))
  end

  @doc """
  Updates a webhook (`PUT /v2/webhooks/:id`).
  """
  @spec update(String.t(), t()) :: Civo.Response.t() | Civo.Error.t()
  def update(id, %__MODULE__{} = params) do
    @path
    |> Path.join(id)
    |> Civo.put(params)
  end

  @doc """
  Sends a test delivery for a webhook (`POST /v2/webhooks/:id/test`).
  """
  @spec test(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def test(id) do
    Path.join([@path, id, "test"])
    |> Civo.post()
  end

  @doc """
  Deletes a webhook (`DELETE /v2/webhooks/:id`).

  Immediate; no confirmation step.
  """
  @spec delete(String.t()) :: Civo.Response.t() | Civo.Error.t()
  def delete(id),
    do: @path |> Path.join(id) |> Civo.delete()
end
