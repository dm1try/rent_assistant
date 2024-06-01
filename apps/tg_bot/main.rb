require_relative 'boot'
require 'drb'
require 'drb_service'
require 'tg_bot_service'

DRbService.new(ENV.fetch("TG_BOT_DRB_URI"), TgBotService.new).start do |service|
  service.start_bot
end

