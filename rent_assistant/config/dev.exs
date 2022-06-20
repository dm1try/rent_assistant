import Config

config :catalog, Catalog.Repo,
  database: "rent_assistant_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :tg_bot, TgBot.Repo,
  database: "rent_assistant_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
