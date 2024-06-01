require 'drb/observer'
require 'json'

class CatalogService
  include DRb::DRbObservable

  def save_listing(attributes)
    db_attributes = attributes.dup
    db_attributes[:created_at] ||= Time.now
    db_attributes[:updated_at] ||= Time.now
    db_attributes[:location] = JSON.dump(attributes[:location])
    db_attributes[:source] = JSON.dump(attributes[:source]) if attributes[:source]
    db_attributes[:images] = JSON.dump(attributes[:images]) if attributes[:images]

    DB[:listings].insert(db_attributes)
  rescue => e
    $logger&.error "Could not save listing: #{e}"
    nil
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
