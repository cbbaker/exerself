# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :api, Api.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nrbREckyi4WTO0drFPyIAsIxfq3KrO8jEKcGNrNKb3et6SMER8qp2tub291Vg6Po",
  render_errors: [view: Api.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Api.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# auth
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("EXERSELF_APP_ID"),
  client_secret: System.get_env("EXERSELF_APP_SECRET")

config :api, Api.Guardian,
  issuer: "Exerself",
  secret_key: System.get_env("EXERSELF_TOKEN_SECRET")

config :api, :authorized_emails, System.get_env("EXERSELF_APP_EMAILS")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
