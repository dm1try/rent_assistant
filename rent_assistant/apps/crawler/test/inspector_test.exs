defmodule Crawler.InspectorTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @tag :skip
  test "it watches for a specific source and parses the listings info" do
    use_cassette("olx_krakow_inspector") do
      {:ok, _pid} =
        start_supervised(
          {Crawler.Inspector,
           parser: Crawler.Sources.Olx.Parser,
           index_page_url: "https://www.olx.pl/d/nieruchomosci/mieszkania/wynajem/krakow/"}
        )

      :timer.sleep(5000)
    end
  end
end
