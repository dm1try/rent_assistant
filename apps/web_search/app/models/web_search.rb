require 'json'
require 'sequel'

class WebSearch < Sequel::Model
  def update_filters(filters)
    new_filters = self.filters.merge(filters)
    update(filters: JSON.dump(new_filters))
  end

  def clear_filters
    update(filters: JSON.dump({}))
  end

  def filters
    JSON.parse(super, symbolize_names: true)
  end

  def state
    JSON.parse(super, symbolize_names: true)
  end

  def update_state(value)
    new_state = self.state.merge(value)
    update(state: JSON.dump(new_state))
  end

  def clear_state
    update(state: JSON.dump({}))
  end
end
