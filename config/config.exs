# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bulls_and_cows_v2,
  ecto_repos: [BullsAndCowsV2.Repo]

# Configures the endpoint
config :bulls_and_cows_v2, BullsAndCowsV2Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TYkUaerQoc1fLjwTOfjYjvjMBEbIlS5HNZkBNQic0vQUjydLaA/8HA9IWhHBFI3x",
  render_errors: [view: BullsAndCowsV2Web.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BullsAndCowsV2.PubSub,
  live_view: [signing_salt: "6pzLBqUU"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
