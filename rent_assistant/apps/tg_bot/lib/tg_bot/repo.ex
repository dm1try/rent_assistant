defmodule TgBot.Repo do
  use Ecto.Repo,
    otp_app: :tg_bot,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    config = Keyword.put(config, :url, System.get_env("DATABASE_URL"))

    {:ok, config}
  end
end
