require 'parser'

class Otodom < Parser
  def parse_index
    get_html(@url).css('div[data-cy="search.listing.organic"] li[data-cy="listing-item"] a[data-cy="listing-item-link"]').each_with_object([]) do |link, results|
      href = link.attr('href')
      results << { url: "https://www.otodom.pl#{href}" }
    end.reverse
  end

  def parse_listing(index_listing)
    document = get_html(index_listing[:url])

    script_data = document.at('script#__NEXT_DATA__').text

    json_data = JSON.parse(script_data)
    ad_data = json_data['props']['pageProps']['ad']
    return nil unless ad_data
    {
      url: ad_data['url'],
      address: parse_address(ad_data),
      price: ad_data['target']['Price'],
      additional_price: ad_data.dig('target', 'Rent') || 0,
      area: parse_area(ad_data),
      rooms: ad_data['target']['Rooms_num'].first.to_i,
      source: {
        id: ad_data['publicId'],
        created_at: ad_data['createdAt'],
        updated_at: ad_data['modifiedAt'] || ad_data['createdAt']
      },
      location: parse_coordinates(ad_data),
      images: parse_images(ad_data),
      description: Nokogiri::HTML(ad_data['description']).text,
      currency: 'PLN',
      city: ad_data.dig('location', 'address', 'city', 'code')
    }
  rescue JSON::ParserError => error
    puts "Unable to parse listing #{error}"
    nil
  end

  private

  def parse_address(ad_data)
    address = ad_data['location']['address']

    case address
    when Array
      address.first['value']
    when Hash
      city = address.dig('city', 'name')
      district = address.dig('district', 'name')
      street = address.dig('street', 'name')
      [city, district, street].compact.join(', ')
    else
      'unknown'
    end
  end

  def parse_coordinates(ad_data)
    [ad_data['location']['coordinates']['latitude'], ad_data['location']['coordinates']['longitude']]
  end

  def parse_area(ad_data)
    Float(ad_data['target']['Area']).to_i
  rescue ArgumentError
    nil
  end

  def parse_images(ad_data)
    ad_data['images'].map { |image| image['large'] }
  end
end
