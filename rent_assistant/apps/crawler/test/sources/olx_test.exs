defmodule Crawler.Sources.OlxTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias Crawler.Sources.Olx.Parser

  setup_all do
    HTTPoison.start()
    :ok
  end

  test "parses listing data from search page" do
    search_page_url = "https://www.olx.pl/d/nieruchomosci/mieszkania/wynajem/krakow/"

    search_page_html =
      use_cassette "index_page_olx_krakow" do
        {:ok, %{body: body}} = HTTPoison.get(search_page_url)
        body
      end

    first_item = Parser.parse_index_listings_page(search_page_html) |> List.first()

    assert first_item == "https://www.olx.pl/d/oferta/2-pokojowe-czyzyny-CID3-IDPFoKg.html"
  end

  test "parses listing information" do
    listing_page_url = "https://www.olx.pl/d/oferta/2-pokojowe-czyzyny-CID3-IDPFoKg.html"

    listing_page_html =
      use_cassette "listing_page_olx_krakow" do
        {:ok, %{body: body}} = HTTPoison.get(listing_page_url)
        body
      end

    expected_parsed_item = %{
      address: "Małopolskie, Kraków, Czyżyny",
      area: 35,
      description:
        "Wynajmę bezpośrednio mieszkanie 2-pokojowe na osiedlu Botanika przy ul. bp. P. Tomickiego.\n\n\nPowierzchnia wynosi 35 m2, w tym:\n\n- salon z aneksem kuchennym \n\n- sypialnia \n\n- łazienka \n\n- przedpokój \n\n- balkon\n\n\nKuchnia wyposażona jest w zmywarkę, lodówkę, płytę indukcyjną+okap i piekarnik.\n\n\nŁazienka wyposażona jest w kabinę, umywalkę, toaletę, pralkę i przestronną szafę w zabudowie.\n\n\nSypialnia i przedpokój wyposażone są w duże szafy w zabudowie.\n\n\nMieszkanie znajduje się na 3-cim piętrze  6-ścio kondygnacyjnego budynku z windą. Budynek powstał w 2018r.\n\nOkna mieszkania wychodzą na zachód.\n\n\n10 min do przystanku tramwajowego i autobusowego (os. Kolorowe).\n\nW pobliżu: Philip Morris, AWF, CH Czyżyny, Politechnika Krakowska, Wyższa Szkoła Europejska im. J. Tischnera, Krakowski Park Technologiczny, Comarch, Plac Centralny, Nowohuckie Centrum Kultury.\n\n\nCena najmu: 2000 zł + ok 460 zł czynszu administracyjnego (w tym zaliczki na ciepłą i zimną wodę, ogrzewanie, śmieci i utrzymanie części wspólnych)  + prąd wg zużucia.\n\n\nIstnieje możliwość wynajęcia miejsca parkingowego w garażu podziemnym - płatne dodatkowo 250zł.\n\n\nPobieram kaucję zwrotną w wysokości 2500 zł\n\n\nDostępne od 1 sierpnia 2022\n\n\nUprzejmie proszę o nie kontaktowanie się z ofertą pośrednictwa.",
      images: [
        "https://ireland.apollo.olxcdn.com:443/v1/files/rtfzw90ehgp43-PL/image;s=1632x1224",
        "https://ireland.apollo.olxcdn.com:443/v1/files/oixvtul3w1qf3-PL/image;s=1632x1224",
        "https://ireland.apollo.olxcdn.com:443/v1/files/82hrrf7pfcpp1-PL/image;s=1632x1224",
        "https://ireland.apollo.olxcdn.com:443/v1/files/rim9f2gituop-PL/image;s=490x1008",
        "https://ireland.apollo.olxcdn.com:443/v1/files/96iabi88c3mf-PL/image;s=1224x1632",
        "https://ireland.apollo.olxcdn.com:443/v1/files/s4rex6mxkqx41-PL/image;s=1224x1632",
        "https://ireland.apollo.olxcdn.com:443/v1/files/zybsrqyomymc1-PL/image;s=1224x1632",
        "https://ireland.apollo.olxcdn.com:443/v1/files/a7rkay3rueeb2-PL/image;s=1632x1224"
      ],
      location: [50.06906, 20.01135],
      price: 2000,
      rooms: 2,
      source: "olx",
      source_created_at: ~U[2022-06-19 17:01:29Z],
      source_id: "763459708",
      source_updated_at: ~U[2022-06-19 17:03:36Z],
      url: "https://www.olx.pl/d/oferta/2-pokojowe-czyzyny-CID3-IDPFoKg.html"
    }

    assert expected_parsed_item == Parser.parse_listing_page(listing_page_html)
  end

  test "parse issue" do
    url =
      "https://www.olx.pl/d/oferta/rezerwacja-brak-kaucji-apartament-nowa-v-dzielnica-CID3-IDNlq2h.html"

    listing_page_html =
      use_cassette "listing_page_with_parsing_problem_olx_krakow" do
        {:ok, %{body: body}} = HTTPoison.get(url)
        body
      end

    assert Parser.parse_listing_page(listing_page_html)
  end
end
