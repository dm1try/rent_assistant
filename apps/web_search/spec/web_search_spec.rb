require 'spec_helper'
require 'models/web_search'

describe WebSearch do
  describe '#update_filters' do
    let(:web_search) { WebSearch.create }

    it 'updates the filters' do
      expect { web_search.update_filters('a' => 1) }.to change { web_search.reload.filters }.to({a:1})
    end

    it 'merges the filters' do
      web_search.update_filters('a' => 1)
      expect { web_search.update_filters('b' => 2) }.to change { web_search.reload.filters }.to({a:1,b:2})
    end
  end

  describe '#clear_filters' do
    let(:web_search) { WebSearch.create(filters: '{"a":1}') }

    it 'clears the filters' do
      expect { web_search.clear_filters }.to change { web_search.reload.filters }.to({})
    end
  end
end
