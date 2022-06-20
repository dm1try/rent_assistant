import Config

config :catalog, Catalog.Repo,
  ssl: true,
  pool_size: 5,
  url: System.get_env("DATABASE_URL")
