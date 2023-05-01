require 'parser/olx'

class ParserFactory
  REGISTERED_PARSERS = [Olx]

  def self.new_for(city, filters = {})
    url = "https://www.olx.pl/nieruchomosci/mieszkania/wynajem/#{city.downcase}/"

    REGISTERED_PARSERS.map do |parser|
      parser.new(url)
    end
  end
end
