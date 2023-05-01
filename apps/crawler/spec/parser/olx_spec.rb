require 'spec_helper'
require 'parser/olx'

RSpec.describe Olx do
  let(:olx) { Olx.new('https://www.olx.pl/nieruchomosci/mieszkania/wynajem/krakow/') }

  describe '#parse_index' do
    it 'returns array of hashes' do
      VCR.use_cassette('olx_krakow_wynajem_index') do
        expect(olx.parse_index).to eq([{:url=>"https://www.olx.pl/d/oferta/do-wynajecia-mieszkanie-2-pokojowe-krakow-bronowice-stanczyka-CID3-IDIqxb0.html"},
          {:url=>"https://www.olx.pl/d/oferta/wynajme-mieszkanie-krakow-radzikowskiego-55m-CID3-IDUeKXb.html"},
          {:url=>"https://www.olx.pl/d/oferta/2pok-kuchnia-51m2-bobrzynskiego-debniki-os-europejskie-eng-CID3-IDUlbYQ.html"},
          {:url=>"https://www.olx.pl/d/oferta/kawalerka-nowa-aleja-29-listopada-ul-woronicza-bezposrednio-CID3-IDRmCIB.html"},
          {:url=>"https://www.olx.pl/d/oferta/sypialnia-duzy-salon-stare-miasto-majowka-CID3-IDSQRbe.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-3-pokojowe-nowoczesne-ul-slusarska-krakow-CID3-IDGazFy.html"},
          {:url=>"https://www.olx.pl/d/oferta/dwa-pokoje-w-mieszkaniu-trzyosobowym-CID3-IDUldLF.html"},
          {:url=>"https://www.olx.pl/d/oferta/kawalerka-do-wynajecia-krakow-ruczaj-kampus-uj-CID3-IDU9SPZ.html"},
          {:url=>"https://www.olx.pl/d/oferta/kawalerka-blisko-tramwaj-kabel-mateczny-bonarka-wielicka-CID3-IDU9SGK.html"},
          {:url=>"https://www.olx.pl/d/oferta/ludwinow-58-m2-2-pok-0-prowizji-CID3-IDUldws.html"},
          {:url=>"https://www.olx.pl/d/oferta/gorka-narodowa-2-pok-mieszkanie-z-osobna-kuchnia-m-postojowe-CID3-IDUhBl6.html"},
          {:url=>"https://www.olx.pl/d/oferta/zabiniec-kluczborska-2-pok-od-zaraz-eng-below-CID3-IDTKk6q.html"},
          {:url=>"https://www.olx.pl/d/oferta/wynajme-mieszkanie-31-m2-CID3-IDO7IVh.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-na-wynajem-2-pokoje-bronowice-ul-stanczyka-balkon-CID3-IDUaBMV.html"},
          {:url=>"https://www.olx.pl/d/oferta/kawalerka-od-zaraz-sodowa-CID3-IDUf5xd.html"},
          {:url=>"https://www.olx.pl/d/oferta/bronowice-piaskowa-2-pokoje-48-m2-parking-CID3-IDTQD7U.html"},
          {:url=>"https://www.olx.pl/d/oferta/nowa-huta-2-pokoje-kuchnia-48-m2-2-balkony-CID3-IDSD9H4.html"},
          {:url=>"https://www.olx.pl/d/oferta/nowe-mieszkanie-z-ciekawym-widokiem-sprawdz-46556-omw-CID3-IDUfqeA.html"},
          {:url=>"https://www.olx.pl/d/oferta/wynajme-od-zaraz-CID3-IDUlcyO.html"},
          {:url=>"https://www.olx.pl/d/oferta/do-wynajecia-2-pokojowe-mieszkanie-bronowicka-29892-omw-CID3-IDUfpH5.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-3-pok-od-teraz-CID3-IDUlcmq.html"},
          {:url=>"https://www.olx.pl/d/oferta/wynajme-mieszkanie-56-metrow-krakow-bociana-siewna-blisko-centrum-CID3-IDUlbRQ.html"},
          {:url=>"https://www.olx.pl/d/oferta/2-pok-apart-ludwinow-basen-silownia-w-cenie-super-lokalizacja-58m2-CID3-IDTTf3W.html"},
          {:url=>"https://www.olx.pl/d/oferta/2-pok-nowe-klimatyzacja-parking-CID3-IDTTwXn.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-do-wynajecie-ul-przewoz-CID3-IDUgDIp.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-plaszow-nowy-bezposrednio-u-wlasciciela-CID3-IDRdlGv.html"},
          {:url=>"https://www.olx.pl/d/oferta/piltza-2-pokoje-rooms-brand-new-top-floor-ostatnie-pietro-CID3-IDU8ZAt.html"},
          {:url=>"https://www.olx.pl/d/oferta/dwupokojowe-z-aneksem-kuchennym-krowodrza-internet-garaz-na-rowery-CID3-IDUlaYY.html"},
          {:url=>"https://www.olx.pl/d/oferta/kawalerka-do-wynajecia-w-krakowie-CID3-IDUlavj.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-do-wynajecia-ul-reduta-od-zaraz-CID3-IDNyxr2.html"},
          {:url=>"https://www.olx.pl/d/oferta/fabryczna-city-4-pokojowy-z-klimatyzacja-od-1-06-2023-CID3-IDTY07F.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-50-m-nowa-huta-os-teatralne-CID3-IDIXZZT.html"},
          {:url=>"https://www.olx.pl/d/oferta/nowy-apartament-65m-3-pokoje-czyzyny-CID3-IDUl9b8.html"},
          {:url=>"https://www.olx.pl/d/oferta/2-pokojowe-mieszkanie-60-m2-przy-dworcu-gl-i-galerii-krk-CID3-IDR9Ofa.html"},
          {:url=>"https://www.olx.pl/d/oferta/studio-kawalerka-do-wynajecia-krakow-azory-gnieznienska-CID3-IDUl87C.html"},
          {:url=>"https://www.olx.pl/d/oferta/ladna-kawalerka-dabie-ul-na-szaniec-dobra-lokalizacja-bezposrednio-CID3-IDIxpVg.html"},
          {:url=>"https://www.olx.pl/d/oferta/klimatyzowany-apartament-3-pok-krakow-ul-nullo-36-rodzina-z-dziecmi-CID3-IDU4PZQ.html"},
          {:url=>"https://www.olx.pl/d/oferta/sympatyczne-mieszkanie-na-wynajem-CID3-IDUihhM.html"},
          {:url=>"https://www.olx.pl/d/oferta/2-pok-47m2-balkon-ul-gornikow-od-1-06-2023-CID3-IDToZsI.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-47-m2-2-niezalezne-pokoje-ul-obozowa-widok-na-lake-CID3-IDREcHx.html"},
          {:url=>"https://www.olx.pl/d/oferta/do-wynajecia-mieszkanie-2-pokojowe-krakow-bronowice-stanczyka-CID3-IDIqxb0.html"},
          {:url=>"https://www.olx.pl/d/oferta/1-pokojowe-ul-bujwida-900m-od-rynku-bez-prowizji-CID3-IDKerCj.html"},
          {:url=>"https://www.olx.pl/d/oferta/wynajme-mieszkanie-pachonskiego-2pokoje-balkon-CID3-IDUl6op.html"},
          {:url=>"https://www.olx.pl/d/oferta/mieszkanie-2-pokojowe-krakow-nowe-czyzyny-osiedle-avia-CID3-IDGgRbS.html"},
          {:url=>"https://www.olx.pl/d/oferta/wynajme-nowe-2-pokojowe-mieszkanie-ul-sliska-CID3-IDUksKk.html"},
          {:url=>"https://www.olx.pl/d/oferta/fajne-2-pokoje-42m2-z-garderoba-i-garazem-ul-hynka-wlasciciel-CID3-IDUgkEu.html"}])
      end
    end
  end

  describe '#parse_listing' do
    let(:subject) { described_class.new('https://www.olx.pl/nieruchomosci/mieszkania/wynajem/krakow/') }
    let(:index_listing) { { url: 'https://www.olx.pl/d/oferta/mieszkanie-3-pok-od-teraz-CID3-IDUlcmq.html' } }

    it 'returns a hash with listing details' do
      VCR.use_cassette('olx_listing') do
        expect(subject.parse_listing(index_listing)).to eq(
          {
            url: 'https://www.olx.pl/d/oferta/mieszkanie-3-pok-od-teraz-CID3-IDUlcmq.html',
            address: 'Małopolskie, Kraków, Stare Miasto',
            city: 'krakow',
            price: 5500,
            location: [50.06026, 19.9396],
            area: 107,
            rooms: 3,
            currency: 'PLN',
            description: "3 pokojowe mieszkanie<br />\nPiętro: 3/5, powierzchnia: 107,5 m2<br />\nSypialnie: 2<br />\nMieszkanie po remoncie",
            images: ["https://ireland.apollo.olxcdn.com:443/v1/files/zjknxnzhnykk-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/989bglpta90f-PL/image;s=1179x799", "https://ireland.apollo.olxcdn.com:443/v1/files/iybwjgsxp1fd2-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/llkysoug6wbk2-PL/image;s=1179x816", "https://ireland.apollo.olxcdn.com:443/v1/files/vus5sc0me7r8-PL/image;s=1179x806", "https://ireland.apollo.olxcdn.com:443/v1/files/3wqudlsodudj3-PL/image;s=1179x819", "https://ireland.apollo.olxcdn.com:443/v1/files/3f8ctleal9jm3-PL/image;s=620x367"],
            source: {:created_at=>"2023-04-30T13:18:50+02:00", :id=>832527222, :updated_at=>"2023-04-30T13:20:58+02:00"}
          }
        )
      end
    end
  end
end
