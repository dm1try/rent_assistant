require 'spec_helper'
require 'parser/otodom'

RSpec.describe Otodom do
  let(:otodom) { described_class.new("https://www.otodom.pl/pl/oferty/wynajem/mieszkanie/warszawa?page=1&limit=36") }

  describe "#parse_index" do
    it "returns array of listings" do
      VCR.use_cassette("otodom_index") do
        expect(otodom.parse_index).to eq([
          {:url=> "https://www.otodom.pl/pl/oferta/piekne-mieszkanie-dwupokojowe-bemowo-bezposrednio-ID4miVr"},
          {:url=> "https://www.otodom.pl/pl/oferta/wynajme-piekne-mieszkanie-w-spokojnej-okolicy-ID4m0Sa"},
          {:url=> "https://www.otodom.pl/pl/oferta/kawalerka-w-swietnej-lokalizacji-na-mokotowie-ID40Di4"}
        ])
      end
    end
  end

  describe "#parse_listing" do
    let(:listing) { {:url=> "https://www.otodom.pl/pl/oferta/piekne-mieszkanie-dwupokojowe-bemowo-bezposrednio-ID4miVr"} }

    it "returns hash with listing details" do
      VCR.use_cassette("otodom_listing") do
        expect(otodom.parse_listing(listing)).to include({
          :url=>"https://www.otodom.pl/pl/oferta/piekne-mieszkanie-dwupokojowe-bemowo-bezposrednio-ID4miVr",
          :address=>"Warszawa, Bemowo, Lazurowa Dolina",
          :price=>2900,
          :additional_price=>575,
          :city=>"warszawa",
          :area=>50,
          currency: 'PLN',
          :rooms=>2,
          :location=>[52.24782081211379, 20.896631494598378],
          :source => {
            created_at: "2023-07-15T14:39:08+02:00",
            updated_at: "2023-07-15T14:42:04+02:00",
            id: "4miVr",
          },
          :images => ["https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6InA2ZWF2Z2VvOG1maTMtQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0.CZ4t44aVpdrqJqbbC0JaYBc31Wv2o51msPXWX1LEVeQ/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6IjNiZWtwa254NGlxMzItQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0._9OHITrxrRWY2VO6wiZOb_mnIdDjS-GkkPQHDK5ydjE/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6ImgzcWdnY2hhbXhuYTItQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0.URt7eWYl8IoYyB2LcLvYnqIcPIXeVVMP2C0bSatv6Nc/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6IjZ2aWtpMGw4b3p0dTMtQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0.dWHph7ftGpZZ-Q1asOGyatwvq2DT80TK140vOZqqGKo/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6ImJwMHdiZHJhM2lxei1BUEwiLCJ3IjpbeyJmbiI6ImVudmZxcWUxYXk0azEtQVBMIiwicyI6IjE0IiwicCI6IjEwLC0xMCIsImEiOiIwIn1dfQ.Xmcp1OLKwAw-_ne0e1g_fY063KRMJilCG_HzBsSHhFM/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6ImkybTcyYzE1c2FqNDItQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0.oWa3zfhfrqVq5g_pmxoBgJSGfkO0eqWyjaOk5P6GRmE/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6Im9uajcyaWFrMGlqODEtQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0.9Y09MxoMJpCDnGhRoX1KlcdwUqWvALDHQHBy4R8maAo/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6InZmZzczbjV4M29xazMtQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0.ehhqsindL_oU_XfUB0Z5Uiv8tIUE8ajYcB2HNyWDfJU/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6Im5sMDU0NDBjczlwdzEtQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0._wK_Nw12hqQc4NEw3O7c3fxqrM7_3v5fv6KmwSvzGD8/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6ImtnOXpxd3B3dmFxZi1BUEwiLCJ3IjpbeyJmbiI6ImVudmZxcWUxYXk0azEtQVBMIiwicyI6IjE0IiwicCI6IjEwLC0xMCIsImEiOiIwIn1dfQ.EC7veRDIEve8Uy7nmqs1XKM8cu1hidDMaJlFqtNKbMM/image;s=1280x1024;q=80", "https://ireland.apollo.olxcdn.com/v1/files/eyJmbiI6Imdnb3htanpsYnZtZDMtQVBMIiwidyI6W3siZm4iOiJlbnZmcXFlMWF5NGsxLUFQTCIsInMiOiIxNCIsInAiOiIxMCwtMTAiLCJhIjoiMCJ9XX0.qp7oKW3eIr09Qxe3NJThDysDWusr1FW1OM0OsRsE438/image;s=1280x1024;q=80"],
          :description => a_string_starting_with("Do wynajęcia"),
        })
      end
    end

    context 'float area' do
      let(:listing) { {url: "https://www.otodom.pl/pl/oferta/mieszkanie-2-pokoje-51-4-m2-ID4hDn0"} }

      it 'parses area' do
        VCR.use_cassette('otodom_float_area') do
          expect(otodom.parse_listing(listing)).to include({
            :area => 51
          })
        end
      end
    end
  end
end