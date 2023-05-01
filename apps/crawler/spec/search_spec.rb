require 'spec_helper'
require 'search'

RSpec.describe Search do
  let(:filters) { { price: {min: 5000, max: 6000} } }

  describe '.create' do
    it 'saves the search' do
      search_id = Search.create(filters)
      expect(search_id).to be_a(Integer)
    end
  end

  describe '#percolate' do
    context 'when listing matches filter' do
      let(:listing) {
        {
          url: 'https://www.olx.pl/d/oferta/mieszkanie-3-pok-od-teraz-CID3-IDUlcmq.html',
          address: 'Małopolskie, Kraków, Stare Miasto',
          price: 5500,
          location: [50.06026, 19.9396],
          area: 107,
          rooms: 3,
          description: "3 pokojowe mieszkanie<br />\nPiętro: 3/5, powierzchnia: 107,5 m2<br />\nSypialnie: 2<br />\nMieszkanie po remoncie",
          images: ["https://ireland.apollo.olxcdn.com:443/v1/files/zjknxnzhnykk-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/989bglpta90f-PL/image;s=1179x799", "https://ireland.apollo.olxcdn.com:443/v1/files/iybwjgsxp1fd2-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/llkysoug6wbk2-PL/image;s=1179x816", "https://ireland.apollo.olxcdn.com:443/v1/files/vus5sc0me7r8-PL/image;s=1179x806", "https://ireland.apollo.olxcdn.com:443/v1/files/3wqudlsodudj3-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/3f8ctleal9jm3-PL/image;s=620x367"],
          source: {:created_at=>"2023-04-30T13:18:50+02:00", :id=>832527222, :updated_at=>"2023-04-30T13:20:58+02:00"}
        }
      }

      let(:not_matching_listing) {
        listing.merge(price: 1000)
      }

      before do
        Search.create(filters)
      end

      it 'returns matched searches' do
        expect(Search.percolate(listing)).to eq([DB[:searches].first[:id]])
        expect(Search.percolate(not_matching_listing)).to eq([])
      end
    end

    context 'when filter is not set' do
      let(:listing) {
        {
          url: 'https://www.olx.pl/d/oferta/mieszkanie-3-pok-od-teraz-CID3-IDUlcmq.html',
          address: 'Małopolskie, Kraków, Stare Miasto',
          price: 5500,
          location: [50.06026, 19.9396],
          area: 107,
          rooms: 3,
          description: "3 pokojowe mieszkanie<br />\nPiętro: 3/5, powierzchnia: 107,5 m2<br />\nSypialnie: 2<br />\nMieszkanie po remoncie",
          images: ["https://ireland.apollo.olxcdn.com:443/v1/files/zjknxnzhnykk-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/989bglpta90f-PL/image;s=1179x799", "https://ireland.apollo.olxcdn.com:443/v1/files/iybwjgsxp1fd2-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/llkysoug6wbk2-PL/image;s=1179x816", "https://ireland.apollo.olxcdn.com:443/v1/files/vus5sc0me7r8-PL/image;s=1179x806", "https://ireland.apollo.olxcdn.com:443/v1/files/3wqudlsodudj3-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/3f8ctleal9jm3-PL/image;s=620x367"],
          source: {:created_at=>"2023-04-30T13:18:50+02:00", :id=>832527222, :updated_at=>"2023-04-30T13:20:58+02:00"}
        }
      }

      before do
        Search.create({})
      end

      it 'returns all searches' do
        expect(Search.percolate(listing)).to eq([DB[:searches].first[:id]])
      end
    end
  end
end
