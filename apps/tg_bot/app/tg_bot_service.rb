require 'drb/drb'
require 'telegram/bot'

class TgBotService

  def initialize
    @crawler = DRbObject.new_with_uri(ENV['CRAWLER_DRB_URI'])
  end

  def start_bot
    @bot_thread = Thread.new do
      Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
        bot.listen do |message|
          if message.text.start_with?('/')
            command_params = message.text[1..].split(' ')
            case command_params[0]
            when 'start'
              bot.api.send_message(chat_id: message.chat.id, text: help_message)
            when 'stop'
              @crawler.unwatch(search_id: message.chat.id)
              bot.api.send_message(chat_id: message.chat.id, text: "You won't receive notifications anymore, #{message.from.first_name}")
            when 'watch'
              @crawler.watch(search_id: message.chat.id, city: command_params[1], filters: {})
            end
          else
            bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you, #{message.from.first_name}. To see available commands, type /start")
          end
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
  end

  def help_message
    %q(Available commands:
      /start - start bot
      /stop - stop bot
      /watch <city> - subscribe to notifications for new listings in <city>)
  end

end
