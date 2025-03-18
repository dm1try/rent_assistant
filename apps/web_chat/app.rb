require 'rack'
require 'erb'
require 'sequel'
require 'json'
require 'turbo-rails'

class WebChatApp
  def self.call(env)
    new.call(env)
  end

  def call(env)
    request = Rack::Request.new(env)
    response = Rack::Response.new

    case request.path
    when '/'
      handle_root(request, response)
    when '/start'
      handle_start(request, response)
    when %r{/chat/\d+}
      handle_chat(request, response)
    else
      response.status = 404
      response.write('Not Found')
    end

    response.finish
  end

  private

  def handle_root(request, response)
    template = ERB.new(File.read('views/index.erb'))
    response.write(template.result(binding))
  end

  def handle_start(request, response)
    chat = Chat.create(active: true, filters: '{}', state: '{}')
    response.redirect("/chat/#{chat.id}")
  end

  def handle_chat(request, response)
    chat_id = request.path.split('/').last.to_i
    chat = Chat[chat_id]

    if chat
      template = ERB.new(File.read('views/chat.erb'))
      response.write(template.result(binding))
    else
      response.status = 404
      response.write('Chat Not Found')
    end
  end
end
