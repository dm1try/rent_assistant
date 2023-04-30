require 'drb/drb'

class CrawlerService
  def crawl
    listing = { city: "Listing title",
      price: 99,
      description: "test",
      area: 99,
      rooms: 99,
      address: "test",
      url: "test",
      currency: "test",
      location: [1, 2],
      created_at: Time.now,
      updated_at: Time.now
    }
    # then call the remote save_listing method on the Catalog application
    catalog = DRbObject.new_with_uri(ENV['CATALOG_DRB_URI'])
    catalog.save_listing(listing)
  rescue DRb::DRbConnError => e
    $logger&.warn "Could not connect to catalog service: #{e}"
  end
end
