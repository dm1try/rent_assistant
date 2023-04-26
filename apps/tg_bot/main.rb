require 'drb'

class TgBotService
  def initialize
    # initialize your Telegram bot here
  end

  def send_message(message)
    # send the message to the user
  end

  def get_filters(user_id)
    # retrieve the filters for the user
  end
end

DRb.start_service('druby://tg_bot:9000', TgBotService.new)
DRb.thread.join
