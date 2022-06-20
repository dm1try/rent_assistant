import Config

config :catalog, Catalog.Repo,
  database: "rent_assistant_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
