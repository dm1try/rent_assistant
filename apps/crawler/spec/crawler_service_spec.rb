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
      expect($logger).to receive(:info).with("Crawling done, sleeping...")
      crawler_service.start_crawling
      sleep 1
    end
  end

  describe '#watch' do
    it 'creates a search' do
      expect { crawler_service.watch(search_id: 1, city: 'Warszawa', filters: []) }.to change { DB[:searches].count }.by(1)
    end

    it 'creates a parser' do
      expect { crawler_service.watch(search_id: 1, city: 'Warszawa', filters: []) }.to change { crawler_service.instance_variable_get(:@parsers).count }.by(1)
    end
  end

  describe '#crawl' do
    let(:parser) { double('parser') }
    let(:listing) { { url: 'https://example.com', title: 'test' } }
    let(:catalog) { double('catalog') }

    before do
      crawler_service.instance_variable_set(:@parsers, [parser])
      crawler_service.instance_variable_set(:@catalog, catalog)
    end

    it 'parses index' do
      expect(parser).to receive(:parse_index).and_return([listing])
      expect(catalog).to receive(:listing_exists?).with('https://example.com').and_return(false)
      expect(parser).to receive(:parse_listing).with(listing).and_return(listing)
      expect(catalog).to receive(:save_listing).with(listing)
      expect(Search).to receive(:percolate).with(listing).and_return([1])
      expect(crawler_service).to receive(:changed)
      expect(crawler_service).to receive(:notify_observers).with(:new_listing, listing: listing, matched_search_ids: [1])

      crawler_service.crawl
    end

    it 'does not parse listing if it exists' do
      expect(parser).to receive(:parse_index).and_return([listing])
      expect(catalog).to receive(:listing_exists?).with('https://example.com').and_return(true)
      expect(parser).not_to receive(:parse_listing).with(listing)
      expect(catalog).not_to receive(:save_listing).with(listing)
      expect(Search).not_to receive(:percolate).with(listing)
      expect(crawler_service).not_to receive(:changed)
      expect(crawler_service).not_to receive(:notify_observers).with(:new_listing, listing: listing, matched_search_ids: [1])

      crawler_service.crawl
    end
  end
end
