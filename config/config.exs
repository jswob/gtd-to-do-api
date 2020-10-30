# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :gtd_to_do_api,
  ecto_repos: [GtdToDoApi.Repo]

# Configures the endpoint
config :gtd_to_do_api, GtdToDoApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vKumS965AlzfV+g/1zUucaJAabo+h/7TGgKTR5hWJgG09+rUCT0BIQUMbxlm7jfN",
  render_errors: [view: GtdToDoApiWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: GtdToDoApi.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
