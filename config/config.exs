import Config

config :logger,
  backends: [:console]

config :logger, :console,
  level: :debug,
  format: "\n$time $metadata[$level] $levelpad$message\n",
  metadata: [:pid]

config :jameson,
  api_key: {:system, :string, "JAMESON_API_KEY"},
  http_port: {:system, :integer, "JAMESON_HTTP_PORT", 80},
  session_timeout: {:system, :integer, "JAMESON_SESSION_TIMEOUT", 60_000},
  db_file: {:system, :charlist, "JAMESON_DB_FILE", 'db'},
  storage_file: {:system, :charlist, "JAMESON_STORAGE_FILE", 'storage'}
