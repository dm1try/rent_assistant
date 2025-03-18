require_relative 'boot'
require 'drb'
require 'drb_service'
require 'web_search_service'

DRbService.new(ENV.fetch("WEB_SEARCH_DRB_URI"), WebSearchService.new).start do |service|
  begin
    crawler = DRb::DRbObject.new_with_uri(ENV['CRAWLER_DRB_URI'])
    crawler.add_observer(service)
  rescue => e
    $logger&.warn "Could not connect to crawler service for observing: #{e}"
  end
  service.start_web_search
end
