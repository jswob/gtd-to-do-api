use Mix.Config

# Configure your database
config :gtd_to_do_api, GtdToDoApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "gtd_to_do_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gtd_to_do_api, GtdToDoApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :bcrypt_elixir, :log_rounds, 4

import_config "test.secret.exs"
