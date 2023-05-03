require 'json'

class Chat < Sequel::Model
  def self.find_or_create_by_tg_id(tg_id)
    find(tg_id: tg_id) || create(tg_id: tg_id)
  end

  def update_filters(filters)
    existing_filters = JSON.parse(self.filters)
    existing_filters.merge!(filters)
    update(filters: JSON.dump(existing_filters))
  end

  def clear_filters
    update(filters: JSON.dump({}))
  end
end
