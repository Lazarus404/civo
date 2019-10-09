# Civo API

![Civo](https://www.civo.com/assets/logo-footer-cbb3e639eee4da339cc26b27f98351fe215828f49dac3874cd036ffbb6f201c7.svg)

## Introduction

This is an Elixir library for interacting with the Civo API. Civo provide superfast, scalable cloud servers with a developer-friendly API – moulded and shaped by their community.

## Installation

this package can be installed by adding `civo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:civo, "~> 0.1.0"}
  ]
end
```

Once installed, you need to add your API key to your applications `config.exs`

```
config :civo,
  api_token: "50m34p1c0d3th4td035ntw0rk"
```

Your API key can be obtained by visiting [Civo's API documentation page](https://www.civo.com/api) while logged in.

## Documentation

Complete documentation is available [here](https://hexdocs.pm/civo/).
