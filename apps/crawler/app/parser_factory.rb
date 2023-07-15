require 'parser/olx'

class ParserFactory
  def self.new_for(city, filters = {})
    [
      Olx.new("https://www.olx.pl/nieruchomosci/mieszkania/wynajem/#{city.downcase}/"),
      Otodom.new("https://www.otodom.pl/pl/oferty/wynajem/mieszkanie/#{city.downcase}?page=1&limit=36")
    ]
  end
end
