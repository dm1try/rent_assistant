require 'rack'
require 'erb'
require 'sequel'
require 'json'
require 'turbo-rails'

class WebSearchApp
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
    when %r{/search/\d+}
      handle_search(request, response)
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
    search = WebSearch.create(active: true, filters: '{}', state: '{}')
    response.redirect("/search/#{search.id}")
  end

  def handle_search(request, response)
    search_id = request.path.split('/').last.to_i
    search = WebSearch[search_id]

    if search
      template = ERB.new(File.read('views/search.erb'))
      response.write(template.result(binding))
    else
      response.status = 404
      response.write('Search Not Found')
    end
  end
end
