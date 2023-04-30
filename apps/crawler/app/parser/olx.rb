require 'parser'

class Olx < Parser
  def parse_index
    get_html(@url).css("div[data-cy=\"l-card\"] a[href^='/d/']").map do |offer|
      href = offer.attr('href')
      {
        url: "https://www.olx.pl#{href}"
      }
    end
  end
end
