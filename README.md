![Civo](assets/logo.svg)

## Introduction

Elixir client for the [Civo](https://www.civo.com) cloud API (`https://api.civo.com/v2`).

## Installation

Add `civo` to your deps:

```elixir
def deps do
  [
    {:civo, "~> 1.0"}
  ]
end
```

Configure your API key (and optional default region) in `config.exs`:

```elixir
config :civo,
  api_token: System.fetch_env!("CIVO_API_TOKEN"),
  region: "LON1"
```

Get an API key from [Civo's API page](https://www.civo.com/api) while logged in.

Most resource operations accept an optional `region` argument. If omitted, the configured `:region` is sent when set.

## Modules

| Module | API |
| --- | --- |
| `Civo.Instances` | Instances, sizes, firewall attach, CivoStack limits |
| `Civo.DiskImages` | Disk images (replaces templates) |
| `Civo.Kubernetes` | K3s clusters, pools, marketplace, versions |
| `Civo.Volumes` | Block storage |
| `Civo.Networks` | Private networks |
| `Civo.Firewalls` | Firewalls and rules |
| `Civo.LoadBalancers` | VPC load balancers |
| `Civo.IPs` | Reserved IPs (assign/unassign) |
| `Civo.InstanceSnapshots` | Per-instance snapshots |
| `Civo.SnapshotSchedules` | Snapshot schedules |
| `Civo.ObjectStores` | Object stores and credentials |
| `Civo.SSH` | SSH keys |
| `Civo.DNS` | Domains and records |
| `Civo.Quota` / `Civo.Charges` / `Civo.Regions` | Account metadata |
| `Civo.WebHooks` | Webhooks |

`/v2/vpc/*` paths on the API are aliases of the networking endpoints above; this client uses the primary `/v2/...` paths.

## Errors

Successful calls return `%Civo.Response{body: ..., status: ..., request: ...}`.
Failures return `%Civo.Error{kind: :http | :transport | :decode, status: ..., body: ..., reason: ..., ...}`.

Missing `api_token`, required create fields, or a required `region` raise `ArgumentError` before the request is sent.

## Breaking changes (1.0)

- Requires Elixir 1.15+
- JSON via Jason; responses are decoded maps/lists (no longer `{:ok, body}`)
- `DELETE` accepts query params (for `region`)
- Kubernetes uses `pools` / `network_id` / `region` (not `num_target_nodes`)
- Load balancers are VPC LBs (not hostname/TLS HTTP LBs)
- Templates and legacy `/v2/snapshots/:name` removed — use disk images and instance snapshots
- Instance `move_ip` removed — use `Civo.IPs`

## License

MIT — see [LICENSE](LICENSE).

## Documentation

HexDocs: [https://hexdocs.pm/civo/](https://hexdocs.pm/civo/)

API reference: [https://www.civo.com/api](https://www.civo.com/api)
