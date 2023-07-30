require 'parser/olx'
require 'parser/otodom'

class ParserFactory
  def self.new_for(city, filters = {})
    otodom_url = 
      case city.downcase
      when 'warszawa'
        "https://www.otodom.pl/pl/wyniki/wynajem/mieszkanie/mazowieckie/warszawa/warszawa/warszawa?page=1&limit=36&by=DEFAULT&direction=DESC&viewType=listing"
      when 'krakow'
        "https://www.otodom.pl/pl/wyniki/wynajem/mieszkanie/malopolskie/krakow/krakow/krakow?page=1&limit=36&by=DEFAULT&direction=DESC&viewType=listing"
      else
        "https://www.otodom.pl/pl/oferty/wynajem/mieszkanie/#{city.downcase}?page=1&limit=36"
      end
    [
      Olx.new("https://www.olx.pl/nieruchomosci/mieszkania/wynajem/#{city.downcase}/?search[order]=created_at:desc"),
      Otodom.new(otodom_url)
    ]
  end
end
