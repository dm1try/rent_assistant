defmodule TgBot.EventsHandler do
  use GenServer
  require Logger
  import Ecto.Query

  @spec start_link(any, [
          {:debug, [:log | :statistics | :trace | {any, any}]}
          | {:hibernate_after, :infinity | non_neg_integer}
          | {:name, atom | {:global, any} | {:via, atom, any}}
          | {:spawn_opt, [:link | :monitor | {any, any}]}
          | {:timeout, :infinity | non_neg_integer}
        ]) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts \\ [], args \\ []) do
    GenServer.start_link(__MODULE__, opts, args)
  end

  def init(_opts) do
    Catalog.EventsManager.subscribe()
    {:ok, %{last_updated: nil}}
  end

  def handle_info({:listing_created, listing}, state) do
    chats = TgBot.Repo.all(from(c in TgBot.Chat, where: c.active == true))

    Enum.each(chats, fn chat ->
      send_listing(chat.chat_id, listing)
    end)

    {:noreply, %{state | last_updated: DateTime.utc_now()}}
  end

  @media_group_items_limit 10
  defp send_listing(chat_id, listing) do
    token = System.get_env("BOT_TOKEN")

    media_group =
      Enum.map(Enum.take(listing.images, @media_group_items_limit), fn image_url ->
        %{type: "photo", media: image_url}
      end)

    created_at_relative =
      case Timex.format(listing.source_created_at, "{relative}", :relative) do
        {:ok, date} ->
          date

        _ ->
          "unknown"
      end

    updated_at_relative =
      case Timex.format(listing.source_updated_at, "{relative}", :relative) do
        {:ok, date} ->
          date

        _ ->
          "unknown"
      end

    caption = """
    Price: #{listing.price}
    Address: #{listing.address}
    Area: #{listing.area}
    Rooms: #{listing.rooms}
    Created #{created_at_relative} and updated #{updated_at_relative}
    #{listing.url}
    """

    media_group =
      media_group
      |> List.update_at(0, fn first_media ->
        %{type: "photo", media: first_media.media, caption: caption}
      end)

    case Telegram.Api.request(token, "sendMediaGroup",
           chat_id: chat_id,
           media: media_group
         ) do
      {:ok, _} ->
        nil

      error ->
        Logger.error("failed to send listing to #{chat_id} #{inspect(error)}")

        Telegram.Api.request(token, "sendMessage",
          chat_id: chat_id,
          text:
            "Something went wrong. I was unable to send you the info about this listing #{listing.url}\n Error: #{inspect(error)}"
        )
    end
  end
end
