require 'drb/observer'
require 'json'

class CatalogService
  include DRb::DRbObservable

  def save_listing(attributes)
    db_attributes = attributes.dup
    db_attributes[:location] = JSON.dump(attributes[:location])

    listing_id = DB[:listings].insert(db_attributes)
    changed
    notify_observers(:new_listing, listing_id, attributes)
  end

  def get_listings
    DB[:listings].map do |listing|
      listing[:location] = JSON.parse(listing[:location])
      listing[:images] = JSON.parse(listing[:images]) if listing[:images]
      listing[:source] = JSON.parse(listing[:source]) if listing[:source]
      listing
    end
  end

  def listing_exists?(url)
    DB[:listings].where(url: url).count > 0
  end
end
