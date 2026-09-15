# Changelog

## 1.0.0

Breaking refresh against current Civo API v2 docs.

- Region-aware HTTP client (`config :civo, region: ...`); `DELETE` supports query params
- Fix JSON decode (`Response.body` is the decoded value, not `{:ok, ...}`)
- Fix `Civo.WebHooks.update/2` path bug
- Rewrite instances, kubernetes (node pools), volumes, firewalls, networks, load balancers
- Replace templates with `Civo.DiskImages`; replace legacy snapshots with `Civo.InstanceSnapshots` and `Civo.SnapshotSchedules`
- Add `Civo.ObjectStores`, `Civo.IPs`, kubernetes versions, JWT `Civo.exchange_token/0`
- Bump Elixir to `~> 1.15`, HTTPoison `~> 2.2`, Jason (replaces Poison); `ex_doc` pinned to `~> 0.40`
- HTTPoison 3 deferred: ExVCR 0.17 is incompatible with hackney 4 response mocking
- Harden HTTP layer: structured `Civo.Error` (`kind`/`status`/`body`/`reason`), safe JSON decode
- Send `region` as a query param on POST/PUT/PATCH and keep it in the JSON body when set
- Raise `ArgumentError` when `api_token`, required create fields, or required region are missing

## 0.1.1

10-10-2019 - Update documentation

## 0.1.0

09-10-2019 - Initial commit ready for hex.pm deployment
