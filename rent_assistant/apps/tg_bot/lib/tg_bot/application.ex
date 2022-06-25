defmodule TgBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    webhook_config = [
      host: System.get_env("HOST"),
      local_port: System.get_env("PORT") |> Kernel.||("3000") |> String.to_integer(),
      set_webhook: false
    ]

    bot_config = [
      token: System.get_env("BOT_TOKEN"),
      max_bot_concurrency: 10
    ]

    children = [
      # Starts a worker by calling: TgBot.Worker.start_link(arg)
      {TgBot.Repo, []},
      {TgBot.EventsHandler, []},
      {Telegram.Webhook, config: webhook_config, bots: [{TgBot.Controller, bot_config}]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TgBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
