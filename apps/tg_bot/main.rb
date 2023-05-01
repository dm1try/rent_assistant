require_relative 'boot'
require 'drb'
require 'drb_service'
require 'tg_bot_service'

DRbService.new(ENV.fetch("TG_BOT_DRB_URI"), TgBotService.new).start do |service|
  begin
    crawler = DRb::DRbObject.new_with_uri(ENV['CRAWLER_DRB_URI'])
    crawler.add_observer(service)
  rescue => e
    $logger&.warn "Could not connect to crawler service for obverving: #{e}"
  end
  service.start_bot
end

