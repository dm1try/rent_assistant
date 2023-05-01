require 'json'

class Search

  def self.active_cities
    DB[:searches].select_map(:city).uniq
  end

  def self.create(search_id, city, filters)
    DB[:searches].insert(search_id: search_id, city: city, filters: JSON.dump(filters))
  end

  def self.delete_by_search_id(search_id)
    DB[:searches].where(search_id: search_id).delete
  end

  def self.percolate(listing)
    DB[:searches].all.each_with_object([]) do |search, found_search_ids|
      filters = JSON.parse(search[:filters], symbolize_names: true)

      if (listing[:price] && filters[:price]) &&
        !(listing[:price] >= filters[:price][:min] && listing[:price] <= filters[:price][:max])
        next
      end

      found_search_ids << search[:search_id]
    end
  end
end
