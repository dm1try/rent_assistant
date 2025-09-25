# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class Catalog
  class Error < StandardError; end

  def initialize(host: ENV.fetch('CATALOG_HOST'))
    @host = host
    @base_uri = URI(@host)
  end

  def listing_exists?(url)
    uri = @base_uri.dup
    uri.path = '/listings/exists'
    uri.query = URI.encode_www_form(url: url)
    res = Net::HTTP.get_response(uri)
    handle_response(res) { |body| body['exists'] }
  end

  def save_listing(data)
    uri = @base_uri.dup
    uri.path = '/listings'
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = data.to_json
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(req)
    end
    handle_response(res) { |body| body['status'] == 'ok' }
  end

  def get_listings
    uri = @base_uri.dup
    uri.path = '/listings'
    res = Net::HTTP.get_response(uri)
    handle_response(res) { |body| body }
  end

  private

  def handle_response(res)
    if res.is_a?(Net::HTTPSuccess)
      body = JSON.parse(res.body)
      yield body
    else
      raise Error, "Catalog API error: #{res.code} #{res.body}"
    end
  end
end
