import Config

# Library defaults — consumers set these in their own config.
config :civo,
  api_token: nil,
  region: nil

import_config "#{config_env()}.exs"
