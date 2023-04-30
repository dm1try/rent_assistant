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
end
