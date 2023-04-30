require 'drb/drb'

class CrawlerService
  def initialize
    @catalog = DRbObject.new_with_uri(ENV['CATALOG_DRB_URI'])
    @parsers = []
  rescue DRb::DRbConnError => e
    $logger&.warn "Could not connect to catalog service: #{e}"
  end

  def start_crawling
    @crawling_thread =  Thread.new do
      loop do
        $logger&.info "Crawling..."
        @parsers.each do |parser|
          index_listings = parser.parse_index
          index_listings.each do |listing|
            next if @catalog.listing_exists?(listing[:url])
            parser.parse_listing(listing).tap do |listing|
              @catalog.save_listing(listing)
            end
          end
        end

        $logger&.info "Crawling done, sleeping..."
        sleep rand(10..30)
      end
    end
  end

  def stop_crawling
    @crawling_thread&.kill
  end
end
