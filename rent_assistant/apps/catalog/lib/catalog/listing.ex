defmodule Catalog.Listing do
  use Ecto.Schema

  schema "listings" do
    field :city,    :string
    field :price,   :integer
    field :description, :string
    field :area,    :integer
    field :rooms,   :integer
    field :address, :string
    field :url,     :string
    field :location, {:array, :float}
    field :source, :string
    field :source_id, :string
    field :source_created_at, :utc_datetime
    field :source_updated_at, :utc_datetime
    field :images, {:array, :string}
    timestamps()
  end
end
