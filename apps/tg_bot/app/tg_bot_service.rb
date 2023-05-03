require 'drb/drb'
require 'telegram/bot'

class TgBotService
  include DRb::DRbUndumped

  def initialize
    @crawler = DRbObject.new_with_uri(ENV['CRAWLER_DRB_URI'])
  end

  def start_bot
    @bot_thread = Thread.new do
      Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
        bot.listen do |message|
          handle_message(bot, message)
        end
      end
    end
    true
  rescue => e
    $logger&.error "Error: #{e}"
    false
  end

  def stop_bot
    @bot_thread&.kill
    true
  end

  def handle_message(bot, message)
    if message.text.start_with?('/')
      command_params = message.text[1..].split(' ')
      case command_params[0]
      when 'start', 'help'
        bot.api.send_message(chat_id: message.chat.id, text: help_message)
      when 'stop'
        @crawler.unwatch(search_id: message.chat.id)
        bot.api.send_message(chat_id: message.chat.id, text: "You won't receive notifications anymore, #{message.from.first_name}")
      when 'watch'
        if command_params[1].nil?
          bot.api.send_message(chat_id: message.chat.id, text: "You need to specify a city, #{message.from.first_name}")
          return
        end

        @crawler.watch(search_id: message.chat.id, city: command_params[1] || 'krakow', filters: {})
        bot.api.send_message(chat_id: message.chat.id, text: "You will receive notifications for new listings in #{command_params[1]}, #{message.from.first_name}")
      when 'filter'
        if command_params[1].nil?
          bot.api.send_message(chat_id: message.chat.id, text: "You need to specify a filter name, #{message.from.first_name}")
          return
        end

        filter_name = command_params[1]
        case filter_name
        when 'price'
          min_price = command_params[2]
          max_price = command_params[3]
          if min_price.nil? || max_price.nil?
            bot.api.send_message(chat_id: message.chat.id, text: "You need to specify min and max price, #{message.from.first_name}")
            return
          end

          @crawler.watch(search_id: message.chat.id, city: 'krakow', filters: {price: {min: min_price.to_i, max: max_price.to_i}})
          bot.api.send_message(chat_id: message.chat.id, text: "You will receive notifications for new listings in Krakow with price between #{min_price} and #{max_price}, #{message.from.first_name}")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you, #{message.from.first_name}. To see available commands, type /start or /help")
      end
    else
      bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you, #{message.from.first_name}. To see available commands, type /start")
    end
  end

  def update(notify_type, args)
    listing = args[:listing]
    matched_search_ids = args[:matched_search_ids]

    $logger&.info "New listing found: #{listing[:url]}"
    matched_search_ids.each do |search_id|
      Telegram::Bot::Api.new(ENV['TELEGRAM_TOKEN']).send_message(chat_id: search_id, text: "New listing found: #{listing[:url]}")
    end
  end

  def help_message
    %q(Available commands:
      /start /help - start bot
      /stop - stop bot
      /watch <city> - subscribe to notifications for new listings in <city>
      /filter price <min_price> <max_price> - set price filter)
  end

end
