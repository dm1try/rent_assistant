# frozen_string_literal: true

require_relative 'catalog_service'
require 'json'
require 'rack'

class CatalogAPI
  def call(env)
    req = Rack::Request.new(env)
    service = CatalogService.new

    case [req.request_method, req.path_info]
    when ['POST', '/listings']
      begin
        data = JSON.parse(req.body.read)
        service.save_listing(data)
        [201, { 'Content-Type' => 'application/json' }, [{ status: 'ok' }.to_json]]
      rescue => e
        [400, { 'Content-Type' => 'application/json' }, [{ error: e.message }.to_json]]
      end
    when ['GET', '/listings']
      listings = service.get_listings
      [200, { 'Content-Type' => 'application/json' }, [listings.to_json]]
    when ['GET', '/listings/exists']
      url = req.params['url']
      if url.nil?
        [400, { 'Content-Type' => 'application/json' }, [{ error: 'Missing url param' }.to_json]]
      else
        exists = service.listing_exists?(url)
        [200, { 'Content-Type' => 'application/json' }, [{ exists: exists }.to_json]]
      end
    else
      [404, { 'Content-Type' => 'application/json' }, [{ error: 'Not found' }.to_json]]
    end
  end
end

# No direct Rack server start; use config.ru instead.
