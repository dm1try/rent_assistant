require 'nokogiri'
require 'open-uri'

class Parser
  def initialize(url)
    @url = url
  end

  def parse_index
    raise NotImplementedError
  end

  def parse_listing(listing)
    raise NotImplementedError
  end

  def get_html(url)
    Nokogiri::HTML(URI.open(@url).read)
  end
end
