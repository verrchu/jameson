import Config

config :logger,
  backends: [:console]

config :logger, :console,
  level: :debug,
  format: "\n$time $metadata[$level] $levelpad$message\n",
  metadata: [:pid]

config :jameson,
  # storage_file: {:system, :charlist, "JAMESON_STORAGE_FILE"},
  # flush_interval: {:system, :integer, "JAMESON_FLUSH_INTERVAL", 1_000},
  api_key: {:system, :string, "JAMESON_API_KEY"},
  http_port: {:system, :integer, "JAMESON_HTTP_PORT", 80},
  session_timeout: {:system, :integer, "JAMESON_SESSION_TIMEOUT", 60_000},
  db_file: {:system, :charlist, "JAMESON_DB_FILE"}
