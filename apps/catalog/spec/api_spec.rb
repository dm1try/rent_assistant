# frozen_string_literal: true
require 'rack/test'
require 'json'
require_relative '../app/api'

RSpec.describe CatalogAPI do
  include Rack::Test::Methods

  def app
    CatalogAPI.new
  end

  let(:listing_data) { { 'url' => 'http://example.com/1', 'title' => 'Test Listing' } }

  describe 'POST /listings' do
    it 'saves a listing and returns 201' do
      post '/listings', listing_data.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)['status']).to eq('ok')
    end

    it 'returns 400 for invalid JSON' do
      post '/listings', 'not-json', { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
    end
  end

  describe 'GET /listings' do
    it 'returns listings as JSON' do
      post '/listings', listing_data.to_json, { 'CONTENT_TYPE' => 'application/json' }
      get '/listings'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to be_a(Array)
    end
  end

  describe 'GET /listings/exists' do
    xit 'returns exists: true for present listing' do
      post '/listings', listing_data.to_json, { 'CONTENT_TYPE' => 'application/json' }
      get '/listings/exists', url: listing_data['url']
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['exists']).to eq(true)
    end

    it 'returns exists: false for missing listing' do
      get '/listings/exists', url: 'http://notfound.com/2'
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['exists']).to eq(false)
    end

    it 'returns 400 if url param is missing' do
      get '/listings/exists'
      expect(last_response.status).to eq(400)
    end
  end
end
