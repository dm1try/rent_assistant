defmodule CatalogTest do
  use ExUnit.Case, async: false

  alias Catalog.Repo
  alias Catalog.Listing

  setup_all do
    Repo.delete_all(Listing)
    :ok
  end

  test "listings persistance" do
    Repo.insert!(%Catalog.Listing{
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

    assert 1 == Repo.aggregate(Listing, :count), "Listing count should be 1"
  end
end
