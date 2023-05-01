require "spec_helper"
require 'catalog_service'

RSpec.describe CatalogService do
  let(:catalog_service) { CatalogService.new }

  it "works" do
    expect(catalog_service.get_listings.count).to eq(0)

    result = catalog_service.save_listing(
      city: "Listing title",
      price: 99,
      description: "test",
      area: 99,
      rooms: 99,
      address: "test",
      url: "test",
      currency: "test",
      location: [1, 2]
    )

    expect(catalog_service.get_listings.count).to eq(1)
    expect(result).to eq(DB[:listings].first[:id])
  end

  context 'when listing attributes are invalid' do
    it 'returns nil' do
      expect(catalog_service.save_listing({})).to eq(nil)
    end

    it 'logs error' do
      expect($logger).to receive(:error)
      catalog_service.save_listing({})
    end
  end
  context 'when saving a listing' do
    let(:listing_attributes) do
      {
        city: "Listing title",
        price: 99,
        description: "test",
        area: 99,
        rooms: 99,
        address: "test",
        url: "test",
        currency: "test",
        location: [1, 2],
        created_at: Time.now,
        updated_at: Time.now
      }
    end
    let(:observer) { double("observer") }

    before do
      allow(observer).to receive(:update)
    end

    it "notifies observers" do
      catalog_service.add_observer(observer)
      catalog_service.save_listing(listing_attributes)

      expect(observer).to have_received(:update).with(:new_listing, DB[:listings].first[:id], listing_attributes)
    end
  end

  describe '#listing_exists?' do
    let(:listing_attributes) do
      {
        city: "Listing title",
        price: 99,
        description: "test",
        area: 99,
        rooms: 99,
        address: "test",
        url: "test",
        currency: "test",
        location: [1, 2],
        created_at: Time.now,
        updated_at: Time.now
      }
    end

    it 'returns true if the listing exists' do
      catalog_service.save_listing(listing_attributes)
      expect(catalog_service.listing_exists?(listing_attributes[:url])).to eq(true)
    end

    it 'returns false if the listing does not exist' do
      expect(catalog_service.listing_exists?(999)).to eq(false)
    end
  end
end
