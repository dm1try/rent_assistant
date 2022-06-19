defmodule Crawler.Inspector do
  require Logger
  use GenServer

  import Ecto.Query

  @update_interval_in_ms 30_000

  def start_link(opts \\ [], args \\ []) do
    GenServer.start_link(__MODULE__, opts, args)
  end

  def init(opts) do
    parser = Keyword.fetch!(opts, :parser)
    index_page_url = Keyword.fetch!(opts, :index_page_url)

    send(self(), :update_tick)
    {:ok, %{last_updated: nil, parser: parser, index_page_url: index_page_url}}
  end

  def handle_info(:update_tick, state) do
    fetch_index(state)
    Process.send_after(self(), :update_tick, @update_interval_in_ms)
    {:noreply, %{state | last_updated: DateTime.utc_now()}}
  end

  def handle_info({_, :ok}, state) do
    {:noreply, state}
  end

  defp fetch_index(state) do
    parser = state.parser

    Logger.debug("start new fetch #{inspect(parser)}")

    headers = %{
      "User-agent":
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36"
    }

    case HTTPoison.get(state.index_page_url, headers) do
      {:ok, %{body: body}} ->
        listing_links = parser.parse_index_listings_page(body)
        Logger.info("Found #{Enum.count(listing_links)} links.")

        Enum.each(listing_links, fn listing_link ->
          query = from(l in Catalog.Listing, where: l.url == ^listing_link)

          if Catalog.Repo.exists?(query) do
            Logger.debug("skip listing: #{listing_link}")
          else
            Logger.debug("fetch listing: #{listing_link}")
            {:ok, %{body: body}} = HTTPoison.get(listing_link, headers)
            parsed_item = parser.parse_listing_page(body)

            if parsed_item do
              parsed_item = %{parsed_item | url: listing_link}
              Catalog.Listings.create(parsed_item)
            else
              Logger.error("failed to parse listing: #{listing_link}")
            end
          end
        end)

      {:error, error} ->
        Logger.error("failed to fetch index: #{inspect(error)}")
    end

    {:ok, %{}}
  end
end
