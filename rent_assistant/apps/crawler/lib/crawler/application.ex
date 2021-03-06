defmodule Crawler.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Crawler.Worker.start_link(arg)
      {Crawler.Inspector,
       parser: Crawler.Sources.Olx.Parser,
       index_page_url: "https://www.olx.pl/d/nieruchomosci/mieszkania/wynajem/krakow/"}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crawler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
