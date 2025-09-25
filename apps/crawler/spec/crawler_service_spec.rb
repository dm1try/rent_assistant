require "spec_helper"
require 'crawler_service'

RSpec.describe CrawlerService do
  let(:crawler_service) { CrawlerService.new }

  describe '#start_crawling' do
    it 'starts crawling' do
      expect(crawler_service.start_crawling).to be_a(Thread)
    end

    it 'logs crawling' do
      expect($logger).to receive(:info).with("Crawling...")
      expect($logger).to receive(:info).with(/Using parsers/)
      expect($logger).to receive(:info) do |arg|
        expect(arg).to match(/Crawling done, sleeping for \d+ seconds.../)
      end
      crawler_service.start_crawling
      sleep 1
    end
  end

  describe '#watch' do
    it 'creates a search' do
      expect { crawler_service.watch(search_id: 1, city: 'Warszawa', filters: []) }.to change { DB[:searches].count }.by(1)
    end
  end

  describe '#unwatch' do
    it 'deletes a search' do
      Search.create('my_search', 'warszawa', {})
      expect { crawler_service.unwatch(search_id: 'my_search') }.to change { DB[:searches].count }.by(-1)
    end
  end

  describe '#crawl' do
    let(:parser) { double('parser') }
    let(:listing) { { url: 'https://example.com', title: 'test' } }
    let(:catalog) { double('catalog') }

    before do
      Search.create('my_search', 'warszawa', {})
      allow(ParserFactory).to receive(:new_for).and_return([parser])
      allow(parser).to receive(:parse_index).and_return([listing])
      crawler_service.instance_variable_set(:@catalog, catalog)
    end

    it 'parses index and publishes to Redis Stream' do
      expect(parser).to receive(:parse_index).and_return([listing])
      expect(catalog).to receive(:listing_exists?).with('https://example.com').and_return(false)
      expect(parser).to receive(:parse_listing).with(listing).and_return(listing)
      expect(catalog).to receive(:save_listing).with(listing)
      expect(Search).to receive(:percolate).with(listing).and_return([1])

      redis = double('redis')
      crawler_service.instance_variable_set(:@redis, redis)
      expect(redis).to receive(:xadd).with('new_listing_stream', {
        listing: JSON.dump(listing),
        matched_search_ids: JSON.dump([1])
      })

      crawler_service.crawl
    end

    it 'does not parse listing if it exists' do
      expect(parser).to receive(:parse_index).and_return([listing])
      expect(catalog).to receive(:listing_exists?).with('https://example.com').and_return(true)
      expect(parser).not_to receive(:parse_listing).with(listing)
      expect(catalog).not_to receive(:save_listing).with(listing)
      expect(Search).not_to receive(:percolate).with(listing)
      redis = double('redis')
      crawler_service.instance_variable_set(:@redis, redis)
      expect(redis).not_to receive(:xadd)

      crawler_service.crawl
    end
  end
end
