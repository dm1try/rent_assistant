require 'spec_helper'
require 'tg_bot_service'

describe TgBotService do
  let(:subject) { described_class.new }

  describe '#start_bot' do
    let(:bot) { double('bot') }
    let(:message) { double('message') }
    let(:chat) { double('chat') }
    let(:from) { double('from') }
    let(:api) { double('api') }

    it 'starts the bot thread' do
      allow(Telegram::Bot::Client).to receive(:run).and_yield(bot)
      allow(bot).to receive(:listen).and_yield(message)
      allow(bot).to receive(:api).and_return(api)
      allow(api).to receive(:send_message).and_return(true)
      allow(message).to receive(:text).and_return('/start')
      allow(message).to receive(:chat).and_return(chat)
      allow(chat).to receive(:id).and_return(1)
      allow(message).to receive(:from).and_return(from)
      allow(from).to receive(:first_name).and_return('John')

      expect(subject.start_bot).to be_truthy
    end
  end

  describe '#stop_bot' do
    it 'stops the bot thread' do
      expect(subject.stop_bot).to be_truthy
    end
  end

  describe '#update' do
    let (:listing) { {id: 1, title: 'title', url: 'url', price: 1000, city: 'krakow', filters: {}} }
    let (:matched_search_ids) { [1] }
    let (:api) { double('api') }

    before do
      allow(Telegram::Bot::Api).to receive(:new).and_return(api)
      allow(api).to receive(:send_message).and_return(true)
    end

    it 'handles update notification from crawler' do
      subject.update('new_listing', listing: listing, matched_search_ids: matched_search_ids)
      expect(api).to have_received(:send_message).with(chat_id: 1, text: "New listing found: #{listing[:url]}")
    end
  end
end
