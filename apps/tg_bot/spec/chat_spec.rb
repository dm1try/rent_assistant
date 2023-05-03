require 'spec_helper'
require 'models/chat'

describe Chat do
  describe '.find_or_create_by_tg_id' do
    context 'when chat does not exist' do
      before do
        DB[:chats].delete
      end

      it 'creates a new chat' do
        expect { Chat.find_or_create_by_tg_id(1) }.to change { Chat.count }.by(1)
      end
    end

    context 'when chat exists' do
      before do
        Chat.create(tg_id: 1)
      end

      it 'does not create a new chat' do
        expect { Chat.find_or_create_by_tg_id(1) }.not_to change { Chat.count }
      end

      it 'returns the existing chat' do
        expect(Chat.find_or_create_by_tg_id(1)).to eq(Chat.first)
      end
    end
  end

  describe '#update_filters' do
    let(:chat) { Chat.create(tg_id: 1) }

    it 'updates the filters' do
      expect { chat.update_filters('a' => 1) }.to change { chat.reload.filters }.to({a:1})
    end

    it 'merges the filters' do
      chat.update_filters('a' => 1)
      expect { chat.update_filters('b' => 2) }.to change { chat.reload.filters }.to({a:1,b:2})
    end
  end

  describe '#clear_filters' do
    let(:chat) { Chat.create(tg_id: 1, filters: '{"a":1}') }

    it 'clears the filters' do
      expect { chat.clear_filters }.to change { chat.reload.filters }.to({})
    end
  end
end
