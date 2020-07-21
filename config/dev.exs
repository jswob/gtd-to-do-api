use Mix.Config

# Configure your database
config :gtd_to_do_api, GtdToDoApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "gtd_to_do_api_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :gtd_to_do_api, GtdToDoApiWeb.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]


config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

import_config "dev.secret.exs"
