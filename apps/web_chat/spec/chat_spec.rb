require 'spec_helper'
require 'models/chat'

describe Chat do
  describe '#update_filters' do
    let(:chat) { Chat.create }

    it 'updates the filters' do
      expect { chat.update_filters('a' => 1) }.to change { chat.reload.filters }.to({a:1})
    end

    it 'merges the filters' do
      chat.update_filters('a' => 1)
      expect { chat.update_filters('b' => 2) }.to change { chat.reload.filters }.to({a:1,b:2})
    end
  end

  describe '#clear_filters' do
    let(:chat) { Chat.create(filters: '{"a":1}') }

    it 'clears the filters' do
      expect { chat.clear_filters }.to change { chat.reload.filters }.to({})
    end
  end
end
