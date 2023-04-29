require 'drb/observer'

class CatalogService
  include DRb::DRbObservable

  def save_listing(attributes)
    db_attributes = attributes.dup
    db_attributes[:location] = Sequel.pg_array(attributes[:location])
    listing_id = DB[:listings].insert(db_attributes)

    changed
    notify_observers(:new_listing, listing_id, attributes)
  end

  def get_listings
    DB[:listings].map do |listing|
      listing[:location] = listing[:location].to_a
      listing
    end
  end
end
