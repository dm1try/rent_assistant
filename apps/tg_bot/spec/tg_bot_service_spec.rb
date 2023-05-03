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

  describe '#handle_message' do
    let(:bot) { double('bot') }
    let(:message) { double('message') }
    let(:chat) { double('chat') }
    let(:from) { double('from') }
    let(:api) { double('api') }

    before do
      allow(bot).to receive(:api).and_return(api)
      allow(api).to receive(:send_message).and_return(true)
      allow(message).to receive(:text)
      allow(message).to receive(:chat).and_return(chat)
      allow(chat).to receive(:id).and_return(1)
      allow(message).to receive(:from).and_return(from)
      allow(from).to receive(:first_name).and_return('John')
      DB[:chats].delete
    end

    context 'when command is /start' do
      before do
        allow(message).to receive(:text).and_return('/start')
      end

      it 'creates a new chat' do
        expect { subject.handle_message(bot, message) }.to change { Chat.count }.by(1)
      end

      it 'sends help message' do
        subject.handle_message(bot, message)
        expect(api).to have_received(:send_message)
      end
    end

    context 'when command is /stop' do
      let(:crawler) { double('crawler') }
      let(:tg_chat) { Chat.create(tg_id: 1, active: true, filters: JSON.dump({})) }

      before do
        allow(chat).to receive(:id).and_return(1)
        subject.instance_variable_set(:@crawler, crawler)
        allow(crawler).to receive(:unwatch)
        allow(message).to receive(:text).and_return('/stop')
      end

      it 'set chat to inactive' do
        subject.handle_message(bot, message)
        expect(Chat.last.active).to be_falsey
      end
    end

    context 'when command is /watch' do
      let(:crawler) { double('crawler') }
      let(:tg_chat) { Chat.create(tg_id: 1, active: true) }

      before do
        subject.instance_variable_set(:@crawler, crawler)
        allow(crawler).to receive(:watch)
        allow(crawler).to receive(:unwatch)
        allow(message).to receive(:text).and_return('/watch krakow')
      end

      it 'set chat to active' do
        subject.handle_message(bot, message)
        expect(Chat.last.active).to be_truthy
      end

      it 'unwatches previous search' do
        subject.handle_message(bot, message)
        expect(crawler).to have_received(:unwatch).with(search_id: 1)
      end
    end

    context 'when command is /filter price <min> <max>' do
      let(:crawler) { double('crawler') }
      let(:tg_chat) { Chat.create(tg_id: 1, active: true) }

      before do
        subject.instance_variable_set(:@crawler, crawler)
        allow(crawler).to receive(:watch)
        allow(message).to receive(:text).and_return('/filter price 100 200')
      end

      it 'updates chat filters' do
        subject.handle_message(bot, message)
        expect(Chat.last.filters).to eq(price: {min: 100, max: 200})
      end
    end

    context 'when command is /status' do
      let(:tg_chat) { Chat.create(tg_id: 1, active: true, filters: JSON.dump({city: 'krakow'})) }

      before do
        tg_chat
        allow(message).to receive(:text).and_return('/status')
      end

      it 'sends status message' do
        subject.handle_message(bot, message)
        expect(api).to have_received(:send_message).with(chat_id: 1, text: "Notifications are ON\nWatching for listings in krakow\n")
      end
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
