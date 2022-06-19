defmodule Crawler.Sources.Olx do
  defmodule Parser do
    @behaviour Crawler.Parser

    require Logger

    def parse_index_listings_page(index_page_html) do
      {:ok, document} = Floki.parse_document(index_page_html)

      Floki.find(document, "div[data-cy=\"l-card\"] a")
      |> Floki.attribute("href")
      |> Enum.filter(fn link -> String.starts_with?(link, "/d/") end)
      |> Enum.map(fn link -> Enum.join(["https://www.olx.pl", link]) end)
      |> Enum.reverse()
    end

    def parse_listing_page(listing_page_html) do
      {:ok, document} = Floki.parse_document(listing_page_html)

      init_script_text =
        Floki.find(document, "script#olx-init-config")
        |> Floki.text(js: true)

      match_data =
        Regex.named_captures(~r/__PRERENDERED_STATE__= "(?<init_json>.*)";/, init_script_text)

      init_json =
        match_data["init_json"]
        |> String.replace(~r/\\\\/, "\\")
        |> String.replace(~r/\\\"/, "\"")
        |> String.replace(~r/\\\\u002F/, "/")
        |> String.replace(~r/\\\\u003C/, "<")
        |> String.replace(~r/\\\\u003E/, ">")
        |> String.replace(~r/\\\\u0026/, "&")
        |> String.replace(~r/\\\\u0027/, "'")
        |> String.replace(~r/\\\\u0022/, "\"")
        |> String.replace(~r/\\\\\"/, "\"")
        |> String.replace(~r/\\\\\n/, "\n")

      case Poison.decode(init_json) do
        {:ok, json} ->
          ad_data = json["ad"]["ad"]

          if ad_data["id"] do
            %{
              url: ad_data["url"],
              source: "olx",
              address: ad_data["location"]["pathName"],
              price: ad_data["price"]["regularPrice"]["value"],
              area: parse_area(ad_data),
              source_id: "#{ad_data["id"]}",
              rooms: parse_rooms(ad_data),
              source_created_at: ad_data["createdTime"] |> parse_date,
              source_updated_at: ad_data["lastRefreshTime"] |> parse_date,
              location: parse_coordinates(ad_data),
              images: ad_data["photos"],
              description: Floki.text(ad_data["description"])
            }
          else
            Logger.warn("Unable to find listing id in json #{inspect(init_json)}")
            nil
          end

        {:error, error} ->
          Logger.warn("Unable to decode listing page: #{inspect(error)}")
          nil
      end
    end

    defp parse_area(ad_data) do
      case ad_data["params"] do
        nil ->
          Logger.warn("Unable to parse area: #{inspect(ad_data)}")

        params ->
          Enum.find_value(params, fn param ->
            if param["key"] == "m" do
              param["normalizedValue"] |> Integer.parse() |> elem(0)
            end
          end)
      end
    end

    defp parse_rooms(ad_data) do
      case ad_data["params"] do
        nil ->
          Logger.warn("Unable to parse rooms: #{inspect(ad_data)}")

        params ->
          Enum.find_value(params, fn param ->
            if param["key"] == "rooms" do
              if param["value"] == "Kawalerka" do
                1
              else
                param["value"] |> String.split() |> List.first() |> String.to_integer()
              end
            end
          end)
      end
    end

    defp parse_date(date) do
      {:ok, date, _} = DateTime.from_iso8601(date)
      date
    end

    defp parse_coordinates(ad_data) do
      [ad_data["map"]["lat"], ad_data["map"]["lon"]]
    end
  end
end
