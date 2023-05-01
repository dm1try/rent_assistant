require 'json'

class Search
  def self.create(filters)
    DB[:searches].insert(filters: JSON.dump(filters))
  end

  def self.percolate(listing)
    DB[:searches].all.each_with_object([]) do |search, found_search_ids|
      filters = JSON.parse(search[:filters], symbolize_names: true)

      if listing[:price] && (listing[:price] >= filters[:price][:min] && listing[:price] <= filters[:price][:max])
        found_search_ids << search[:id]
      end
    end
  end
end
