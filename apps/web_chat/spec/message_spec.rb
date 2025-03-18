require 'spec_helper'
require 'models/message'

describe Message do
  let(:chat) { Chat.create }
  let(:message) { Message.create(chat: chat, content: 'Hello, world!') }

  describe '#before_create' do
    it 'sets the created_at timestamp' do
      expect(message.created_at).not_to be_nil
    end
  end

  describe '#chat' do
    it 'returns the associated chat' do
      expect(message.chat).to eq(chat)
    end
  end

  describe '#content' do
    it 'returns the message content' do
      expect(message.content).to eq('Hello, world!')
    end
  end
end
