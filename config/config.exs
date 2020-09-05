import Config

config :jameson,
  storage_file: {:system, :charlist, "JAMESON_STORAGE_FILE"},
  flush_interval: {:system, :integer, "JAMESON_FLUSH_INTERVAL", 1_000}
