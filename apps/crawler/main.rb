require 'drb'

class CrawlerService
  def initialize
    # initialize your crawler here
  end

  def crawl
    # perform the crawling operation
    listing = { title: 'Listing title', price: 100, url: 'http://example.com' }
    # then call the remote save_listing method on the Catalog application
    catalog = DRbObject.new_with_uri('druby://catalog:9000')
    catalog.save_listing(listing)
    2
  end
end

DRb.start_service('druby://crawler:9000', CrawlerService.new)
DRb.thread.join
