require 'redis'
require 'search'
require 'parser_factory'
require_relative 'catalog'

class CrawlerService

  def initialize
    @redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379/0')
    @catalog = Catalog.new
  end

  def watch(search_id:, city:, filters: {})
    Search.create(search_id, city, filters)
  end

  def unwatch(search_id:)
    Search.delete_by_search_id(search_id)
  end

  def crawl
    parsers = Search.active_cities.each_with_object([]) do |city, available_parsers|
      available_parsers.concat(ParserFactory.new_for(city))
    end
    $logger&.info "Using parsers: #{parsers.map(&:class).map(&:name).join(', ')}"

    parsers.each do |parser|
      rollbar_scope = {:parser => parser.class.name}
      parser.parse_index.each do |listing|
        listing_url = listing[:url]
        rollbar_scope[:listing_url] = listing_url
        next if @catalog.listing_exists?(listing_url)
        Rollbar.scope!(rollbar_scope)
        listing = parser.parse_listing(listing)
        unless listing
          $logger&.warn "Could not parse listing #{listing_url}"
          Rollbar.warning("Could not parse listing #{listing_url}")
          next
        end
        listing.tap do |listing|
          @catalog.save_listing(listing)
          matched_search_ids = Search.percolate(listing)
          $logger&.info "percolated listing #{listing[:url]} to #{matched_search_ids.count} searches}"
          if matched_search_ids.any?
            @redis.xadd('new_listing_stream', {
              listing: JSON.dump(listing),
              matched_search_ids: JSON.dump(matched_search_ids)
            })
          end
        end
      end
    end
  rescue => e
    Rollbar.error(e)
    $logger&.error "Parser error: #{e}"
  end

  def start_crawling
    @crawling_thread =  Thread.new do
      loop do
        $logger&.info "Crawling..."
        crawl

        sleep_time = rand(10..30)
        $logger&.info "Crawling done, sleeping for #{sleep_time} seconds..."
        sleep sleep_time
      end
    end
  end

  def stop_crawling
    @crawling_thread&.kill
  end
end
