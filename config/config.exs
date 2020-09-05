import Config

config :jameson,
  storage_file: {:system, :charlist, "JAMESON_STORAGE_FILE"},
  check_interval: {:system, :integer, "JAMESON_CHECK_INTERVAL", 1_000}
