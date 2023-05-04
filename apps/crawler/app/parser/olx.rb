require 'parser'

class Olx < Parser
  def parse_index
    get_html(@url).css("#div-gpt-ad-listing-sponsored-ad ~ div[data-cy=\"l-card\"] a[href^='/d/']").map do |offer|
      href = offer.attr('href')
      {
        url: "https://www.olx.pl#{href}"
      }
    end
  end

  def parse_listing(index_listing)
    html = get_html(index_listing[:url])
    init_script_text = html.at("script#olx-init-config").text

    init_json_match = init_script_text.match(/__PRERENDERED_STATE__= "(?<init_json>.*)";/)
    init_json = init_json_match["init_json"]
      .gsub(/\\\\/, "\\")
      .gsub(/\\\"/, "\"")
      .gsub(/\\\\u002F/, "/")
      .gsub(/\\\\u003C/, "<")
      .gsub(/\\\\u003E/, ">")
      .gsub(/\\\\u0026/, "&")
      .gsub(/\\\\u0027/, "'")
      .gsub(/\\\\u0022/, "\"")
      .gsub(/\\\\\"/, "\"")
      .gsub(/\\\\\n/, "\n")

    begin
      json = JSON.parse(init_json)
    rescue JSON::ParserError => e
      $logger.warn("Unable to decode listing page: #{e.message}")
      return nil
    end

    ad_data = json.dig("ad", "ad")
    if ad_data["id"]
      {
        url: ad_data["url"],
        city: ad_data.dig("location", "cityNormalizedName"),
        address: ad_data.dig("location", "pathName"),
        price: ad_data.dig("price", "regularPrice", "value"),
        area: dig_area(ad_data),
        rooms: dig_rooms(ad_data),
        location: dig_location(ad_data),
        images: ad_data["photos"],
        description: ad_data.dig("description"),
        currency: ad_data.dig("price", "regularPrice", "currencyCode"),
        source:{
          id: ad_data["id"],
          created_at: ad_data["createdTime"],
          updated_at: ad_data["lastRefreshTime"],
        }
      }
    else
      $logger.warn("Unable to find listing id in json #{init_json}")
      nil
    end
  end

  def dig_area(ad_data)
    ad_data.dig("params").find { |param| param["key"] == "m" }["normalizedValue"].to_i
  end

  def dig_rooms(ad_data)
    rooms_eng = ad_data.dig("params").find { |param| param["key"] == "rooms" }["normalizedValue"]
    case rooms_eng
    when "one"
      1
    when "two"
      2
    when "three"
      3
    when "four"
      4
    when "five"
      5
    else
      nil
    end
  end

  def dig_location(ad_data)
    map = ad_data['map']
    [map['lat'], map['lon']] if map
  end
end
