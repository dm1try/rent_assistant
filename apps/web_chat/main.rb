require_relative 'boot'
require 'drb'
require 'drb_service'
require 'web_chat_service'

DRbService.new(ENV.fetch("WEB_CHAT_DRB_URI"), WebChatService.new).start do |service|
  begin
    crawler = DRb::DRbObject.new_with_uri(ENV['CRAWLER_DRB_URI'])
    crawler.add_observer(service)
  rescue => e
    $logger&.warn "Could not connect to crawler service for observing: #{e}"
  end
  service.start_web_chat
end
