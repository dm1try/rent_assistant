require 'json'

class Search
  def self.create(city, filters)
    DB[:searches].insert(city: city, filters: JSON.dump(filters))
  end

  def self.percolate(listing)
    DB[:searches].all.each_with_object([]) do |search, found_search_ids|
      filters = JSON.parse(search[:filters], symbolize_names: true)

      if (listing[:price] && filters[:price]) &&
        !(listing[:price] >= filters[:price][:min] && listing[:price] <= filters[:price][:max])
        next
      end

      found_search_ids << search[:id]
    end
  end
end
