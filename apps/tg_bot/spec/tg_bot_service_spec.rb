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
      allow(message).to receive(:message_id).and_return(1)
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
      let(:tg_chat) { Chat.create(tg_id: 1, active: true, filters: JSON.dump({})) }

      before do
        allow(chat).to receive(:id).and_return(1)
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

      it 'sends message about choosing city' do
        subject.handle_message(bot, message)
        expect(api).to have_received(:send_message) do |args|
          expect(args[:text]).to include('You should choose a city at least')
        end
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

      it 'sends message about choosing filters' do
        subject.handle_message(bot, message)
        expect(api).to have_received(:send_message) do |args|
          expect(args[:text]).to include('Choose a filter or clear all of them')
        end
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
        expect(api).to have_received(:send_message) do |args|
          expect(args[:text]).to include('Watching')
        end
      end
    end
  end

  xdescribe '#update' do
  end
end
