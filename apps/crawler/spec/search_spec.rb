require 'spec_helper'
require 'search'

RSpec.describe Search do
  let(:city) { 'krakow' }
  let(:filters) { { price: {min: 5000, max: 6000} } }
  let(:custom_id) { 'search' }

  describe '.create' do
    it 'saves the search' do
      search_id = Search.create(custom_id, city, filters)
      expect(search_id).to be_a(Integer)
    end
  end

  describe '.delete_by_search_id' do
    it 'deletes the search by its custom id' do
      Search.create(custom_id, city, filters)
      expect { Search.delete_by_search_id(custom_id) }.to change { DB[:searches].count }.by(-1)
    end
  end

  describe '#percolate' do
    context 'when listing matches price filter' do
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
        Search.create(custom_id, city, filters)
      end

      it 'returns matched searches' do
        expect(Search.percolate(listing)).to eq([DB[:searches].first[:search_id]])
        expect(Search.percolate(not_matching_listing)).to eq([])
      end
    end

    context 'when listing matches area filter' do
      let(:filters) { { area: {min: 100, max: 200} } }
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
        listing.merge(area: 50)
      }

      before do
        Search.create(custom_id, city, filters)
      end

      it 'returns matched searches' do
        expect(Search.percolate(listing)).to eq([DB[:searches].first[:search_id]])
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
        Search.create(custom_id, city, {})
      end

      it 'returns all searches' do
        expect(Search.percolate(listing)).to eq([DB[:searches].first[:search_id]])
      end
    end

    context 'when listing matches city filter' do
      let(:filters) { { city: 'krakow' } }
      let(:listing) {
        {
          url: 'https://www.olx.pl/d/oferta/mieszkanie-3-pok-od-teraz-CID3-IDUlcmq.html',
          address: 'Małopolskie, Kraków, Stare Miasto',
          price: 5500,
          location: [50.06026, 19.9396],
          area: 107,
          rooms: 3,
          city: 'krakow',
          description: "3 pokojowe mieszkanie<br />\nPiętro: 3/5, powierzchnia: 107,5 m2<br />\nSypialnie: 2<br />\nMieszkanie po remoncie",
          images: ["https://ireland.apollo.olxcdn.com:443/v1/files/zjknxnzhnykk-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/989bglpta90f-PL/image;s=1179x799", "https://ireland.apollo.olxcdn.com:443/v1/files/iybwjgsxp1fd2-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/llkysoug6wbk2-PL/image;s=1179x816", "https://ireland.apollo.olxcdn.com:443/v1/files/vus5sc0me7r8-PL/image;s=1179x806", "https://ireland.apollo.olxcdn.com:443/v1/files/3wqudlsodudj3-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/3f8ctleal9jm3-PL/image;s=620x367"],
          source: {:created_at=>"2023-04-30T13:18:50+02:00", :id=>832527222, :updated_at=>"2023-04-30T13:20:58+02:00"}
        }
      }

      before do
        Search.create(custom_id, city, filters)
      end

      it 'returns matched searches' do
        expect(Search.percolate(listing)).to eq([DB[:searches].first[:search_id]])
      end
    end

    context 'when listing does not match city filter' do
      let(:filters) { { city: 'warsaw' } }
      let(:listing) {
        {
          url: 'https://www.olx.pl/d/oferta/mieszkanie-3-pok-od-teraz-CID3-IDUlcmq.html',
          address: 'Małopolskie, Kraków, Stare Miasto',
          price: 5500,
          location: [50.06026, 19.9396],
          area: 107,
          rooms: 3,
          city: 'krakow',
          description: "3 pokojowe mieszkanie<br />\nPiętro: 3/5, powierzchnia: 107,5 m2<br />\nSypialnie: 2<br />\nMieszkanie po remoncie",
          images: [],
          source: {:created_at=>"2023-04-30T13:18:50+02:00", :id=>832527222, :updated_at=>"2023-04-30T13:20:58+02:00"}
        }
      }

      before do
        Search.create(custom_id, city, filters)
      end

      it 'returns empty array' do
        expect(Search.percolate(listing)).to eq([])
      end
    end
  end
end
