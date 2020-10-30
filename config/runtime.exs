import Config

if config_env() == :prod do
  config :gtd_to_do_api, GtdToDoApi.Auth.Guardian,
    issuer: "gtd_to_do_api",
    secret_key: System.get_env("GUARDIAN_SECRET_KEY")
end
