import Config

config :logger, level: :warning

config :logger, :console,
  format: "$date $time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id]

config :enfys,
  mode: nil


# Import environment specific config
try do
  import_config "#{config_env()}.exs"
rescue
  _ in File.Error ->
    nil

  error ->
    reraise error, __STACKTRACE__
end
