require "spec_helper"
require 'crawler_service'

RSpec.describe CrawlerService do
  let(:crawler_service) { CrawlerService.new }

  context 'with working catalog service' do
    let(:catalog) { double('catalog', save_listing: true) }

    before do
      allow(DRbObject).to receive(:new_with_uri).and_return(catalog)
    end

    it "saves listing using catalog" do
      crawler_service.crawl
      expect(catalog).to have_received(:save_listing)
    end
  end
end
