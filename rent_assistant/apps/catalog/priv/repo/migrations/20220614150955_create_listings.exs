defmodule Catalog.Repo.Migrations.CreateListings do
  use Ecto.Migration

  def change do
    create table("listings") do
      add :city,    :string, size: 40
      add :price,   :integer
      add :description, :text
      add :area,    :integer
      add :rooms,   :integer
      add :address, :string
      add :url,    :string
      add :source_created_at, :utc_datetime
      add :source_updated_at, :utc_datetime
      add :location, {:array, :float}
      add :source, :string
      add :source_id, :string
      add :images, {:array, :string}

      timestamps()
    end
  end
end
