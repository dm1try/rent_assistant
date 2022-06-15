defmodule CatalogListingsTest do
  use ExUnit.Case, async: false

  setup_all do
    Catalog.Repo.delete_all(Catalog.Listing)
    :ok
  end

  test "it inserts a new listing" do
    Catalog.Listings.create(%{
      city: "New York",
      price: 100,
      description: "Nice house",
      area: 100,
      rooms: 2,
      address: "123 Main St",
      url: "http://example.com",
      source_created_at: DateTime.utc_now() |> DateTime.truncate(:second),
      source_updated_at: DateTime.utc_now() |> DateTime.truncate(:second),
      location: [40.730610, -73.935242],
      source: "example.com",
      source_id: "123",
      images: ["http://example.com/image1.jpg", "http://example.com/image2.jpg"]
    })

    assert 1 == Catalog.Repo.aggregate(Catalog.Listing, :count), "Listing count should be 1"
  end

  test "xit sends notificaiton" do

  end
end
