defmodule Crawler.Parser do
  @doc """
  Parses index pages, retrieves links to the listings.
  """
  @callback parse_index_listings_page(String.t) :: {:ok, term} | {:error, String.t}

  @doc """
  Parses a full information for a specific listing.
  """
  @callback parse_listing_page(String.t) :: {:ok, term} | {:error, String.t}
end
