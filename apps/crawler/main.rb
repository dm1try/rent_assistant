require 'drb'
require 'socket'
class CrawlerService
  def initialize
    # initialize your crawler here
  end

  def crawl
    # perform the crawling operation
    listing = { title: 'Listing title', price: 100, url: 'http://example.com' }
    # then call the remote save_listing method on the Catalog application
    catalog_drb_uri = ENV['CATALOG_DRB_URI']
    catalog = DRbObject.new_with_uri('druby://catalog:9001')
    catalog.save_listing(listing)
  end
end

begin
  atttempts ||= 0
  DRb.start_service(ENV.fetch("CRAWLER_DRB_URI"), CrawlerService.new)
  DRb.thread.join
rescue => e
  atttempts += 1
  if atttempts < 3
    puts "Could not connect to crawler service: #{ENV["CRAWLER_DRB_URI"]}, retrying..."
    sleep 5
    retry
  end
end



