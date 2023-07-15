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
    puts Nokogiri::HTML(ad_data['description']).text
    {
      url: ad_data['url'],
      source: 'otodom',
      address: parse_address(ad_data),
      price: ad_data['target']['Price'],
      area: parse_area(ad_data),
      source_id: ad_data['publicId'],
      rooms: ad_data['target']['Rooms_num'].first.to_i,
      source_created_at: ad_data['createdAt'],
      source_updated_at: ad_data['modifiedAt'] || ad_data['createdAt'],
      location: parse_coordinates(ad_data),
      images: parse_images(ad_data),
      description: Nokogiri::HTML(ad_data['description']).text
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
    Integer(ad_data['target']['Area'])
  rescue ArgumentError
    nil
  end

  def parse_images(ad_data)
    ad_data['images'].map { |image| image['large'] }
  end
end
