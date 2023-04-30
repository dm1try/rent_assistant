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
    headers = {
      "User-agent" =>
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 Safari/537.36"
    }
    Nokogiri::HTML(URI.open(url, headers).read)
  end
end
