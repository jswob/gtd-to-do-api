use Mix.Config

config :gtd_to_do_api, GtdToDoApiWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "gtd-to-do-api.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

config :gtd_to_do_api, GtdToDoApi.Repo,
  ssl: true,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
