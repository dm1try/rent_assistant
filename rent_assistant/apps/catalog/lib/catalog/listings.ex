defmodule Catalog.Listings do
  alias Catalog.Listing
  alias Catalog.Repo

  def create(attributes) do
    changeset = Ecto.Changeset.change(%Listing{}, attributes)
    new_listing = Repo.insert!(changeset)
    Catalog.EventsManager.notify(CatalogEventsManager, :listing_created, new_listing)
  end
end
