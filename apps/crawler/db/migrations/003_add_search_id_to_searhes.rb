Sequel.migration do
  change do
    add_column :searches, :search_id, String
  end
end
