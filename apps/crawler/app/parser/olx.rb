require 'parser'

class Olx < Parser
  def parse_index
    get_html(@url).css("div[data-cy=\"l-card\"] a[href^='/d/']").each_with_object([]) do |offer, results|
      next if offer.css("div[data-testid='adCard-featured']").any?
      href = offer.attr('href')
      results << { url: "https://www.olx.pl#{href}" }
    end.reverse
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
    unless ad_data
      Rollbar.warn("Unable to find ad data in json #{init_json}")
      return nil
    end
    
    if ad_data["id"]
      {
        url: ad_data["url"],
        city: ad_data.dig("location", "cityNormalizedName"),
        address: ad_data.dig("location", "pathName"),
        price: ad_data.dig("price", "regularPrice", "value"),
        additional_price: dig_additional_price(ad_data),
        area: dig_area(ad_data) || 0,
        rooms: dig_rooms(ad_data) || 0,
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
    return nil if ad_data.nil? || ad_data["params"].nil? || ad_data["params"].empty?
  
    param = ad_data["params"].find { |param| param["key"] == "m" }
    
    return nil if param.nil? || param["normalizedValue"].nil?
  
    param["normalizedValue"].to_i
  end

  def dig_rooms(ad_data)
    rooms_val = ad_data.dig("params").find { |param| param["key"] == "rooms" }
    return nil unless rooms_val

    rooms_eng = rooms_val["normalizedValue"]
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

  def dig_additional_price(ad_data)
    rent_param = ad_data['params'].find { |param| param["key"] == "rent" }
    return 0 unless rent_param

    rent_param["normalizedValue"].to_i
  end
end
