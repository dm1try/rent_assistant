Sequel.migration do
  change do
    create_table(:listings) do
      primary_key :id
      String :city, null: false
      Integer :price, null: false
      String :description, text: true, null: false
      Integer :area, null: false
      Integer :rooms, null: false
      String :address, null: false
      String :url, null: false
      String :currency, null: false
      String :location, text: true, null: false # JSON
      String :images, text: true # JSON
      String :source, text: true # JSON
      Time :created_at, null: false
      Time :updated_at, null: false
    end
  end
end
